FROM mcr.microsoft.com/devcontainers/go:1.20

# install aws cli manually with a version before latest as latest has a bug at the moment...
# https://stackoverflow.com/questions/77464352/aws-cli-v2-installation-issue
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.13.33.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install -i /usr/local/aws-cli -b /usr/local/bin \
    && rm awscliv2.zip
