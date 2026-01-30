

# This document outlines the deployment strategy, security practices, and troubleshooting steps for the DevOps Assessment project.

---

## 1. Setup Guide

### Local Environment

To run the application on your local machine:

1. **Clone the Repository**: `git clone https://github.com/Dhanushgowda10/devops-assessment.git`
2. **Environment Variables**: Create a `.env` file in the root directory with `DEBUG=True` and `ALLOWED_HOSTS=localhost,127.0.0.1`.
3. **Launch Containers**: Run `docker compose up -d --build`.
4. **Access the App**:
* **Frontend**: [http://44.200.208.111:8055](http://44.200.208.111:8055)
* **Backend API**: [http://98.92.81.147:8000/api/hello/](http://98.92.81.147:8000/api/hello/)



### Production Environment (AWS EC2)

The infrastructure is managed via **Terraform** and deployed through **GitHub Actions**.

1. **Infrastructure**: Terraform provisions a VPC, Security Groups (Ports 80, 8000, 22), and a `t3.micro` EC2 instance.
2. **CI/CD Pipeline**:
* On a push to the `main` branch, the workflow initializes Terraform to get the server IP.
* It then SSHs into the EC2 instance, clones the latest code, and builds the containers.


3. **Post-Deployment**: The pipeline automatically runs Django migrations inside the container.

---

## 2. Troubleshooting Log: The "Build-Time Paradox"

**Challenge**:
After a successful deployment to AWS, the frontend was reachable, but the "Backend Status" displayed a **Connection Failed** error. Upon inspecting the browser's Network Tab, I discovered the React application was attempting to fetch data from `http://localhost:8000/api/hello/` instead of the EC2 Public IP.

**Root Cause**:
In Vite-based applications, environment variables (like `VITE_API_URL`) are **compile-time constants**. They are "baked" into the static JavaScript files during the `npm run build` phase. Because the build was occurring without the specific EC2 IP being passed into the Docker build context, Vite defaulted the API URL to `localhost`.

**Solution**:
I implemented a **Build Argument** strategy:

1. Updated the `frontend/Dockerfile` to include `ARG VITE_API_URL` before the build command.
2. Configured `docker-compose.yml` to map the host environment variable to the build argument.
3. Updated the GitHub Actions workflow to export the dynamically generated EC2 IP and use the `sudo -E docker compose up --build` command to ensure the new IP was successfully "baked" into the production assets.

---

## 3. Best Practices & Security

* **Multi-Stage Builds**: The frontend uses a multi-stage Dockerfile (Node.js for building, Nginx for serving) to minimize the final image size.
* **Non-Root Execution**: The frontend container runs as the `nginx` user rather than `root` to follow the principle of least privilege.


* **Security Groups**: Only essential ports (80, 8000) are exposed to the public internet via Terraform.

---
# Screenshots
## Application Screenshot
<img src="https://github.com/Dhanushgowda10/devops-assessment/blob/main/screenshots/screenshot-2026-01-25_19-01-43.png" alt="Banner" />

## Container running user
<img src="https://github.com/Dhanushgowda10/devops-assessment/blob/main/screenshots/screenshot-2026-01-25_19-03-28.png" alt="Banner" />


## 4. Submission Details

* **Public Repository**: [https://github.com/Dhanushgowda10/devops-assessment](https://github.com/Dhanushgowda10/devops-assessment)
* **Deployed URL**: [[ttp://44.200.208.111:8055](http://44.200.208.111:8055/admin/login)]
