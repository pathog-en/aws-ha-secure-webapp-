from fastapi import FastAPI, HTTPException

app = FastAPI()

# Track whether the app finished startup
is_ready = False


@app.on_event("startup")
def startup_event():
    global is_ready
    # If this function completes, the app is considered ready
    is_ready = True


@app.get("/")
def root():
    return {"status": "ok", "service": "aws-ha-secure-webapp"}


@app.get("/health")
def health():
    if not is_ready:
        raise HTTPException(status_code=503, detail="service not ready")

    return {"status": "healthy"}

