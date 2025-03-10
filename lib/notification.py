import asyncio
import websockets
import json

connected_clients = set()

async def handler(websocket, path):
    connected_clients.add(websocket)
    try:
        async for message in websocket:
            print(f"Received message: {message}")
    finally:
        connected_clients.remove(websocket)

async def order_success():
    message = json.dumps({
        "title": "Đặt hàng thành công",
        "body": "Đơn hàng của bạn đã được đặt thành công."
    })
    if connected_clients:
        await asyncio.wait([client.send(message) for client in connected_clients])

async def main():
    async with websockets.serve(handler, "localhost", 8080):
        print("Server started")
        while True:
            await asyncio.sleep(5)
            await order_success()

asyncio.run(main())