FROM python:alpine
RUN python3 -m pip install pgn_to_sqlite
ENTRYPOINT ["pgn-to-sqlite"]