import requests
import random

base_url = "https://en.wikipedia.org/w/api.php?action=query&format=json&pageids="
s = requests.get(base_url + str(random.randint(10, 21529208)))