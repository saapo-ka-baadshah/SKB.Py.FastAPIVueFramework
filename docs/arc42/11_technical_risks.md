# Risks and Technical Debts

| Risk / debt | Impact | Mitigation or follow-up |
|---|---|---|
| Docker Engine was unavailable during validation. | Image builds, service health, Kafka listener behavior, and live trace flow remain unverified. | Start Docker and run the documented Compose build/up, endpoint, broker-health, and trace-ingestion checks. |
| Kafka is a single-node plaintext broker with no client authentication. | It is unsuitable for shared/untrusted networks and provides no broker high availability. | Bind host access to loopback as configured; do not use this development profile in production. Specify TLS/SASL and a multi-broker design separately if needed. |
| No current application producer/consumer contract is specified. | A broker replacement could be mistaken for an application messaging feature. | Keep broker-service delivery separate from any future producer/consumer requirement. |
| Browser and container network addresses differ. | Frontend API calls can fail if configured with a Compose-only DNS name. | Define a browser-resolvable API URL or same-origin proxy and test it from the browser. |
| The web Compose file is an overlay and cannot run standalone. | Invoking it without the base file omits the shared network and infrastructure definitions. | Use the documented two-file command and path-independent helper scripts. |
| Root `deploy/docker-compose.yml` uses floating `latest` images for several infrastructure services. | Reproducibility and upgrade behavior can change over time. | Consider pinning tested image versions; no version pinning requirement is currently specified. |
| The frontend does not currently call the FastAPI service. | Future browser code could incorrectly use Compose-only DNS and fail outside the container network. | Use a browser-resolvable API URL or same-origin proxy if browser-side API behavior is added. |
| The arc42 describes configured services that have not been exercised at runtime. | Readers could mistake static configuration for a healthy running deployment. | Keep the runtime verification gap explicit until the Docker build, health, and trace checks pass. |
