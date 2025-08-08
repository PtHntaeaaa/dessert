import asyncio, aiohttp, time, argparse, sys
from tqdm import tqdm

async def worker(session, url, stats, pbar):
    while True:
        t0 = time.perf_counter()
        try:
            async with session.get(url) as resp:
                await resp.read()
                cost = time.perf_counter() - t0
                stats["ok"] += 1
                stats["sum_time"] += cost
                stats["max_time"] = max(stats["max_time"], cost)
        except Exception as e:
            stats["err"] += 1
            stats["last_err"] = str(e)
        finally:
            stats["finished"] += 1
            pbar.update(1)
            await asyncio.sleep(0)

async def main(url, concurrency, duration):
    stats = {"ok": 0, "err": 0, "sum_time": 0.0, "max_time": 0.0, "finished": 0}
    timeout = aiohttp.ClientTimeout(total=10)
    conn = aiohttp.TCPConnector(limit=0, ssl=False)
    async with aiohttp.ClientSession(connector=conn, timeout=timeout) as session:
        pbar = tqdm(desc="requests", unit="req")
        tasks = [asyncio.create_task(worker(session, url, stats, pbar))
                 for _ in range(concurrency)]
        await asyncio.sleep(duration)
        for t in tasks:
            t.cancel()
    pbar.close()

    total = stats["ok"] + stats["err"]
    if total == 0:
        print("没有完成任何请求")
        return
    avg = stats["sum_time"] / stats["ok"] if stats["ok"] else float("nan")
    qps = total / duration
    print("\n----- 结果 -----")
    print(f"成功: {stats['ok']} | 错误: {stats['err']}")
    print(f"QPS: {qps:.2f}")
    print(f"平均响应: {avg*1000:.2f} ms")
    print(f"最大响应: {stats['max_time']*1000:.2f} ms")
    if stats["err"]:
        print("最后一条错误:", stats["last_err"])

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="网站压测")
    parser.add_argument("-u", "--url", required=True, help="目标 URL")
    parser.add_argument("-c", "--concurrency", type=int, default=100, help="并发数 (默认100)")
    parser.add_argument("-d", "--duration", type=int, default=10, help="压测秒数 (默认10)")
    args = parser.parse_args()

    try:
        asyncio.run(main(args.url, args.concurrency, args.duration))
    except KeyboardInterrupt:
        sys.exit("\n手动中断")