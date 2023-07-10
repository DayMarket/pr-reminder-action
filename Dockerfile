FROM swift:5.8.1

COPY src /app

RUN cd /app && \
    swift build

CMD ["swift", "run", "--package-path", "/app"]