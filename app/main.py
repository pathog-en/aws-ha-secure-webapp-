from fastapi import FastAPI, HTTPException
from contextlib import asynccontextmanager

# Track whether the app finished startup
is_ready = False


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Lifespan handler replaces deprecated startup/shutdown events.
    Code before `yield` runs at startup.
    Code after `yield` runs at shutdown.
    """
    global is_ready

    # ---- Startup logic ----
    is_ready = True

    yield

    # ---- Shutdown logic ----
    is_ready = False


app = FastAPI(lifespan=lifespan)


@app.get("/")
def root():
    return {"status": "ok", "service": "aws-ha-secure-webapp"}


@app.get("/health")
def health():
    if not is_ready:
        raise HTTPException(status_code=503, detail="service not ready")

    return {"status": "healthy"}


