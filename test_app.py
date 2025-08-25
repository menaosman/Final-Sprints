import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_main_route(client):
    rv = client.get('/')
    assert b'Welcome to Employee Management System!' in rv.data

def test_health_route(client):
    rv = client.get('/health')
    assert b'OK' in rv.data

def test_live_route(client):
    rv = client.get('/live')
    assert b'live' in rv.data

def test_how_are_you_route(client):
    rv = client.get('/how-are-you')
    assert b'I am good, how about you?' in rv.data