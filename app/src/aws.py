from src.settings import settings

import boto3


class AWS:
    def __init__(self, access_key, secret_key, session_token):
        creds = {
            "aws_access_key_id": access_key,
            "aws_secret_access_key": secret_key,
            "aws_session_token": session_token
        }

        self.sts = boto3.client('sts', **creds)


aws = AWS(
    access_key=settings.aws.access_key_id,
    secret_key=settings.aws.secret_access_key,
    session_token=settings.aws.session_token,
)
