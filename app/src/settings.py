from pydantic_settings import BaseSettings, SettingsConfigDict


class AppSettings(BaseSettings):
    model_config = SettingsConfigDict(env_file="./env/app.env", env_prefix="app_")

    name: str
    admin_email: str
    api_key: str


class AWSSettings(BaseSettings):
    model_config = SettingsConfigDict(env_file="./env/aws.env", env_prefix="aws_")

    access_key_id: str
    secret_access_key: str
    session_token: str


class DatabaseSettings(BaseSettings):
    model_config = SettingsConfigDict(env_file="./env/db.env", env_prefix="db_")

    username: str
    password: str
    host: str
    port: str
    database: str


class VaultSettings(BaseSettings):
    model_config = SettingsConfigDict(env_file="./env/vault.env", env_prefix="vault_")

    proxy_address: str
    transit_mount: str
    transit_key: str
    transform_mount: str
    transform_role: str


class Settings(BaseSettings):
    app: AppSettings = AppSettings()
    aws: AWSSettings = AWSSettings()
    db: DatabaseSettings = DatabaseSettings()
    vault: VaultSettings = VaultSettings()


settings = Settings()
