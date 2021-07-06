# MongoDB Server

The [MongoDB](https://www.mongodb.com) is a NoSQL server. The MongoDB server will
be started in a dockerized environment through [`docker-compose.yml`](docker-compose.yml).

Assuming the project name/context of the docker compose file is `mongodb`:

- MongoDB data will be stored in the Docker volume `mongodb_data`.
- The server will run in the Docker network `mongodb_net`.
- From outside the Docker network the MongoDB can be reached on ports `27017-27019` on `localhost`.

Start the service (working directory `mongodb`):

```bash
docker-compose up -d
# Shutdown (might take a moment)
docker-compose down
```

## Test the container

1. Setup a virtual environment and install the requirements (working directory: `mongodb`)

    ```bash
    python3 -m venv venv
    source venv/bin/activate
    pip install pymongo
    ```

2. Run the sample script. The script prints the database contents and adds an entry to the database using the [pymongo](https://api.mongodb.com/python/current/tutorial.html) API. If you run the script multiple times, the number of database entries should accumulate.

    ```bash
    python3 mongo_sample.py
    ```

    Note: Due to the persistent volume, your entries should not be lost after stopping and starting the container.

**Important**: The json-style entries are not intended for storing binary data. Use the Python [gridfs](https://api.mongodb.com/python/current/api/gridfs/index.html#module-gridfs) API for this purpose.

