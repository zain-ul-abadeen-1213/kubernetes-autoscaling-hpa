"""Tiny CPU-burning web app for HPA demos.

Every request does a short burst of math, so generating HTTP load
raises the pod's CPU usage enough for the Horizontal Pod Autoscaler
to react. Serves a simple branded page.
"""
import math
import os
from http.server import BaseHTTPRequestHandler, HTTPServer

PAGE = """<!DOCTYPE html>
<html><head><title>Zain Tech Automation Solutions</title></head>
<body style="font-family:sans-serif;text-align:center;margin-top:60px">
<h1>Zain Tech Automation Solutions</h1>
<p>Automate. Accelerate. Achieve.</p>
<p>Kubernetes HPA demo app &mdash; pod: {host}</p>
</body></html>"""


def burn_cpu():
    total = 0.0
    for i in range(1, 30000):
        total += math.sqrt(i)
    return total


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        burn_cpu()
        body = PAGE.format(host=os.uname().nodename).encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/html")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        pass


if __name__ == "__main__":
    HTTPServer(("0.0.0.0", 80), Handler).serve_forever()
