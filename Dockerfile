# FROM python:3.12-slim

# WORKDIR /app

# # Copy requirements and install dependencies
# COPY requirements.txt .
# RUN pip install --no-cache-dir -r requirements.txt

# # Copy your application
# COPY . .

# # Expose the port Hugging Face expects
# EXPOSE 7860

# # Run your FastAPI app
# CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "7860"]

# RUN apt-get update && apt-get install -y \
#     unixodbc \
#     unixodbc-dev \
#     && rm -rf /var/lib/apt/lists/*


FROM python:3.12-slim

WORKDIR /app

# 1️⃣ Install system dependencies + build tools
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    unixodbc \
    unixodbc-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 2️⃣ Add Microsoft key (modern way)
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor \
    | tee /usr/share/keyrings/microsoft-prod.gpg > /dev/null

# 3️⃣ Add Microsoft SQL repo (Debian 12!)
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] \
    https://packages.microsoft.com/debian/12/prod bookworm main" \
    > /etc/apt/sources.list.d/mssql-release.list

# 4️⃣ Install SQL Server ODBC driver
RUN apt-get update && ACCEPT_EULA=Y apt-get install -y \
    msodbcsql17 \
    && rm -rf /var/lib/apt/lists/*

# 5️⃣ Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 6️⃣ Copy application
COPY . .

EXPOSE 7860

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "7860"]
