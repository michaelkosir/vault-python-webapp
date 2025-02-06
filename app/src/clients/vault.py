from src.settings import settings

from urllib.parse import quote
import requests_unixsocket
import base64
import hvac


class Vault:
    def __init__(self, proxy_address, transit_mount, transit_key, transform_mount, transform_role):
        if proxy_address.startswith(("http://", "https://")):
            client = hvac.Client(url=proxy_address)

        elif proxy_address.startswith("unix://"):
            encoded = quote(proxy_address.removeprefix("unix://"), safe='')
            url = "http+unix://" + encoded
            session = requests_unixsocket.Session()
            client = hvac.Client(url=url, session=session)

        else:
            client = hvac.Client(url="http://localhost:8200")

        self.cl = client
        self.transit_mount = transit_mount
        self.transit_key = transit_key
        self.transform_mount = transform_mount
        self.transform_role = transform_role

    def _b64e(self, m):
        return base64.b64encode(m.encode()).decode()

    def _b64d(self, m):
        return base64.b64decode(m).decode()

    def random(self, n):
        r = self.cl.secrets.transit.generate_random_bytes(
            mount_point=self.transit_mount,
            n_bytes=n
        )
        return r["data"]["random_bytes"]

    def encrypt(self, m):
        r = self.cl.secrets.transit.encrypt_data(
            mount_point=self.transit_mount,
            name=self.transit_key,
            plaintext=self._b64e(m)
        )
        return r["data"]["ciphertext"]

    def decrypt(self, m):
        r = self.cl.secrets.transit.decrypt_data(
            mount_point=self.transit_mount,
            name=self.transit_key,
            ciphertext=m
        )
        return self._b64d(r["data"]["plaintext"])

    def encode(self, m, t):
        r = self.cl.secrets.transform.encode(
            mount_point=self.transform_mount,
            role_name=self.transform_role,
            transformation=t,
            value=m,
        )
        return r["data"]["encoded_value"]

    def decode(self, m, t):
        r = self.cl.secrets.transform.decode(
            mount_point=self.transform_mount,
            role_name=self.transform_role,
            transformation=t,
            value=m,
        )
        return r["data"]["decoded_value"]


vault = Vault(
    proxy_address=settings.vault.proxy_address,
    transit_mount=settings.vault.transit_mount,
    transit_key=settings.vault.transit_key,
    transform_mount=settings.vault.transform_mount,
    transform_role=settings.vault.transform_role,
)
