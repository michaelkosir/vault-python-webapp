from pydantic_settings import BaseSettings, SettingsConfigDict


class AppSettings(BaseSettings):
    model_config = SettingsConfigDict(env_file="./env/app.env", env_prefix="app_")

    name: str = "Awesome API"
    admin_email: str = ""
    api_key: str = ""


class AWSSettings(BaseSettings):
    model_config = SettingsConfigDict(env_file="./env/aws.env", env_prefix="aws_")

    access_key: str = ""
    secret_key: str = ""
    session_token: str = ""


class DatabaseSettings(BaseSettings):
    model_config = SettingsConfigDict(env_file="./env/db.env", env_prefix="db_")

    username: str = "postgres"
    password: str = "dev"
    host: str = "127.0.0.1"
    port: str = "5432"
    database: str = "postgres"


class VaultSettings(BaseSettings):
    model_config = SettingsConfigDict(env_file="./env/vault.env", env_prefix="vault_")

    proxy_address: str = "127.0.0.1:8200"
    transit_mount: str = "transit"
    transit_key: str = "example"
    transform_mount: str = "transform"
    transform_role: str = "example"


class Settings(BaseSettings):
    app: AppSettings = AppSettings()
    aws: AWSSettings = AWSSettings()
    db: DatabaseSettings = DatabaseSettings()
    vault: VaultSettings = VaultSettings()


settings = Settings()
