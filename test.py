import asyncio
import os
import subprocess
import time

import aiohttp
from dotenv import load_dotenv

# Load environment variables from.env file
load_dotenv()
GCP_PROJECT_ID = os.getenv('GCP_PROJECT_ID')
if GCP_PROJECT_ID is None:
    print("Error: GCP_PROJECT_ID variable not set in .env file.")

process = subprocess.run(['gcloud', 'auth', 'print-identity-token'], capture_output=True, text=True)
TOKEN = process.stdout.strip()

process = subprocess.run(['gcloud', 'api-gateway', 'gateways', 'list',
                         '--project', GCP_PROJECT_ID,
                         '--format', 'table(defaultHostname)'],
                        capture_output=True, text=True)
URL = next((line for line in process.stdout.splitlines() if 'hello' in line), None)

async def fetch(session, url):
    start_time = time.time()
    async with session.get(url, headers={'Authorization': f'Bearer {TOKEN}'}) as response:
        end_time = time.time()
        response_text = await response.text()
        elapsed_time_ms = (end_time - start_time) * 1000
        return response_text, elapsed_time_ms

async def main():
    urls = [f"https://{URL}/hello?name=World"] * 50
    async with aiohttp.ClientSession() as session:
        tasks = [fetch(session, url) for url in urls]
        responses = await asyncio.gather(*tasks)
        for i, (response, elapsed_time_ms) in enumerate(responses):
            print(f"{i+1}. {response} ({elapsed_time_ms:.2f} ms)")

asyncio.run(main())