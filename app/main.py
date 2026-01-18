import os
import random
from typing import Optional

from fastapi import FastAPI, Request, Form
from fastapi.responses import HTMLResponse, JSONResponse, RedirectResponse
from itsdangerous import BadSignature, URLSafeSerializer

app = FastAPI()

# --- Config ---
# IMPORTANT: in production, set this as an env var in Kubernetes
SECRET_KEY = os.getenv("APP_SECRET_KEY", "dev-only-change-me")
serializer = URLSafeSerializer(SECRET_KEY, salt="guessing-game")

MIN_NUM = int(os.getenv("GAME_MIN", "1"))
MAX_NUM = int(os.getenv("GAME_MAX", "100"))

COOKIE_NAME = "guess_game"


def _new_game_state() -> dict:
    return {"target": random.randint(MIN_NUM, MAX_NUM), "attempts": 0}


def _read_state(request: Request) -> dict:
    cookie = request.cookies.get(COOKIE_NAME)
    if not cookie:
        return _new_game_state()

    try:
        state = serializer.loads(cookie)
        if not isinstance(state, dict) or "target" not in state:
            return _new_game_state()
        return state
    except BadSignature:
        return _new_game_state()


def _write_state(response, state: dict):
    token = serializer.dumps(state)
    response.set_cookie(
        COOKIE_NAME,
        token,
        httponly=True,
        samesite="lax",
    )


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.get("/", response_class=HTMLResponse)
def home():
    return """
    <html>
      <head><title>AWS HA Secure Web App</title></head>
      <body style="font-family: Arial; max-width: 720px; margin: 40px auto;">
        <h1>AWS HA Secure Web App</h1>
        <p><a href="/health">Health</a></p>
        <p><a href="/game">Number Guessing Game</a></p>
      </body>
    </html>
    """


@app.get("/game", response_class=HTMLResponse)
def game_page():
    return f"""
    <html>
      <head>
        <title>Number Guessing Game</title>
      </head>
      <body style="font-family: Arial; max-width: 720px; margin: 40px auto;">
        <h1>Number Guessing Game</h1>
        <p>I'm thinking of a number between <b>{MIN_NUM}</b> and <b>{MAX_NUM}</b>.</p>

        <form method="post" action="/game/guess">
          <input type="number" name="guess" min="{MIN_NUM}" max="{MAX_NUM}" required />
          <button type="submit">Guess</button>
        </form>

        <form method="post" action="/game/reset" style="margin-top: 16px;">
          <button type="submit">Reset Game</button>
        </form>

        <p style="margin-top: 24px;"><a href="/">Back</a></p>
      </body>
    </html>
    """


@app.post("/game/guess")
def make_guess(request: Request, guess: int = Form(...)):
    state = _read_state(request)
    state["attempts"] = int(state.get("attempts", 0)) + 1
    target = int(state["target"])

    if guess < target:
        msg = "Too low."
    elif guess > target:
        msg = "Too high."
    else:
        msg = f"Correct! You got it in {state['attempts']} attempts. Starting a new game..."
        state = _new_game_state()

    response = HTMLResponse(
        f"""
        <html>
          <head><title>Result</title></head>
          <body style="font-family: Arial; max-width: 720px; margin: 40px auto;">
            <h2>{msg}</h2>
            <p><a href="/game">Try again</a></p>
            <p><a href="/">Home</a></p>
          </body>
        </html>
        """
    )
    _write_state(response, state)
    return response


@app.post("/game/reset")
def reset_game():
    response = RedirectResponse(url="/game", status_code=303)
    _write_state(response, _new_game_state())
    return response



