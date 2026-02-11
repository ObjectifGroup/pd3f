import json
import time

import requests

files = {
    "pdf": (
        "test.pdf",
        open(
            "../pd3f-core/tests/test_data/00020/00020_08112014_Stellungnahme_RAK_Koeln_RefE_Bekaempfung_Korruption.pdf",
            "rb",
        ),
    )
}
response = requests.post(
    "http://localhost:1616",
    files=files,
    data={
        "lang": "de",
        "parsr_adjust_cleaner_config": json.dumps(
            [["reading-order-detection", {"minVerticalGapWidth": 20}]]
        ),
    },
)
id = response.json()["id"]

deadline = time.time() + 60 * 30  # 30 minutes

while time.time() < deadline:
    r = requests.get(f"http://localhost:1616/update/{id}")
    j = r.json()

    if j.get("failed"):
        log = j.get("log", "")
        raise RuntimeError(f"pd3f job failed:\n{log}")

    if "text" in j:
        break

    if "position" in j:
        print(f"queued (position={j['position']})...")
    elif j.get("running"):
        print("running...")
    else:
        print("waiting...")
    time.sleep(1)

if "text" not in j:
    raise TimeoutError(f"pd3f job did not finish in time (job id: {id})")

print(j["text"])
