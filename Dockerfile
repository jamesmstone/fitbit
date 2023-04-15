FROM python:alpine
RUN python3 -m pip install fitbit-to-sqlite
ENTRYPOINT ["fitbit-to-sqlite"]