from locust import HttpUser, task


class HelloWorldUser(HttpUser):
    @task
    def hello_world(self):
        self.client.get(
            "/https://9i4xur6529.execute-api.eu-west-2.amazonaws.com/development/path1")
