# Overly aggressive CFS

We're looking at CPU bandwidth control via CFS:

* https://www.kernel.org/doc/Documentation/scheduler/sched-bwc.txt

## Reproduction program

Program does number of iterations, in each iteration we burn CPU in small chunks
until we get 5ms of real time spent. On each iteration we also print how much
time we spent burning CPU, how much real time passed and how much CPU time.

If we don't go over CFS quota, we should always get very close to 5ms.

If we go over quota, it's fair to expect to have higher real timings,
while on-CPU time should remain around 5ms.

To make tests easier, we run code in a docker container. Code is in `cfs.go`.

We tested:

* Kernel 4.14.4, 4.9.51 and 4.4.88 on bare metal with NUMA
* Xubuntu 17.04 with kernel 4.10.0-19-generic on VirtualBox
* Ubuntu 16.04 with kernel 4.4.0-101-generic on DigitalOcean
* Fedora 27 with kernel 4.13.9-300.fc27.x86_64 on DigitalOcean

All with the same results.

### Running without throttling

#### 100ms sleep between iterations

As expected, nothing is throttled.

```
$ docker run --rm -it -v $(pwd):$(pwd) -w $(pwd) golang:1.9.2 go run cfs.go -iterations 100 -sleep 100ms
2017/12/08 01:39:54 [0] burn took 5ms, real time so far: 5ms, cpu time so far: 6ms
2017/12/08 01:39:54 [1] burn took 5ms, real time so far: 110ms, cpu time so far: 11ms
2017/12/08 01:39:55 [2] burn took 5ms, real time so far: 215ms, cpu time so far: 17ms
2017/12/08 01:39:55 [3] burn took 5ms, real time so far: 320ms, cpu time so far: 23ms
2017/12/08 01:39:55 [4] burn took 5ms, real time so far: 425ms, cpu time so far: 29ms
2017/12/08 01:39:55 [5] burn took 5ms, real time so far: 530ms, cpu time so far: 35ms
2017/12/08 01:39:55 [6] burn took 5ms, real time so far: 635ms, cpu time so far: 40ms
2017/12/08 01:39:55 [7] burn took 5ms, real time so far: 741ms, cpu time so far: 46ms
2017/12/08 01:39:55 [8] burn took 5ms, real time so far: 846ms, cpu time so far: 52ms
2017/12/08 01:39:55 [9] burn took 5ms, real time so far: 951ms, cpu time so far: 57ms
2017/12/08 01:39:55 [10] burn took 5ms, real time so far: 1056ms, cpu time so far: 63ms
2017/12/08 01:39:55 [11] burn took 5ms, real time so far: 1161ms, cpu time so far: 68ms
2017/12/08 01:39:56 [12] burn took 5ms, real time so far: 1266ms, cpu time so far: 75ms
2017/12/08 01:39:56 [13] burn took 5ms, real time so far: 1371ms, cpu time so far: 80ms
2017/12/08 01:39:56 [14] burn took 5ms, real time so far: 1476ms, cpu time so far: 86ms
2017/12/08 01:39:56 [15] burn took 5ms, real time so far: 1582ms, cpu time so far: 92ms
2017/12/08 01:39:56 [16] burn took 5ms, real time so far: 1687ms, cpu time so far: 98ms
2017/12/08 01:39:56 [17] burn took 5ms, real time so far: 1792ms, cpu time so far: 104ms
2017/12/08 01:39:56 [18] burn took 5ms, real time so far: 1897ms, cpu time so far: 109ms
2017/12/08 01:39:56 [19] burn took 5ms, real time so far: 2002ms, cpu time so far: 116ms
2017/12/08 01:39:56 [20] burn took 5ms, real time so far: 2107ms, cpu time so far: 121ms
2017/12/08 01:39:57 [21] burn took 5ms, real time so far: 2212ms, cpu time so far: 127ms
2017/12/08 01:39:57 [22] burn took 5ms, real time so far: 2317ms, cpu time so far: 134ms
2017/12/08 01:39:57 [23] burn took 5ms, real time so far: 2423ms, cpu time so far: 139ms
2017/12/08 01:39:57 [24] burn took 5ms, real time so far: 2528ms, cpu time so far: 145ms
2017/12/08 01:39:57 [25] burn took 5ms, real time so far: 2633ms, cpu time so far: 150ms
2017/12/08 01:39:57 [26] burn took 5ms, real time so far: 2738ms, cpu time so far: 157ms
2017/12/08 01:39:57 [27] burn took 5ms, real time so far: 2843ms, cpu time so far: 162ms
2017/12/08 01:39:57 [28] burn took 5ms, real time so far: 2948ms, cpu time so far: 169ms
2017/12/08 01:39:57 [29] burn took 5ms, real time so far: 3053ms, cpu time so far: 175ms
2017/12/08 01:39:57 [30] burn took 5ms, real time so far: 3158ms, cpu time so far: 180ms
2017/12/08 01:39:58 [31] burn took 5ms, real time so far: 3264ms, cpu time so far: 187ms
2017/12/08 01:39:58 [32] burn took 5ms, real time so far: 3369ms, cpu time so far: 192ms
2017/12/08 01:39:58 [33] burn took 5ms, real time so far: 3474ms, cpu time so far: 198ms
2017/12/08 01:39:58 [34] burn took 5ms, real time so far: 3579ms, cpu time so far: 203ms
2017/12/08 01:39:58 [35] burn took 5ms, real time so far: 3684ms, cpu time so far: 210ms
2017/12/08 01:39:58 [36] burn took 5ms, real time so far: 3789ms, cpu time so far: 215ms
2017/12/08 01:39:58 [37] burn took 5ms, real time so far: 3894ms, cpu time so far: 221ms
2017/12/08 01:39:58 [38] burn took 5ms, real time so far: 3999ms, cpu time so far: 227ms
2017/12/08 01:39:58 [39] burn took 5ms, real time so far: 4104ms, cpu time so far: 233ms
2017/12/08 01:39:59 [40] burn took 5ms, real time so far: 4209ms, cpu time so far: 239ms
2017/12/08 01:39:59 [41] burn took 5ms, real time so far: 4315ms, cpu time so far: 244ms
2017/12/08 01:39:59 [42] burn took 5ms, real time so far: 4420ms, cpu time so far: 250ms
2017/12/08 01:39:59 [43] burn took 5ms, real time so far: 4525ms, cpu time so far: 255ms
2017/12/08 01:39:59 [44] burn took 5ms, real time so far: 4630ms, cpu time so far: 262ms
2017/12/08 01:39:59 [45] burn took 5ms, real time so far: 4735ms, cpu time so far: 268ms
2017/12/08 01:39:59 [46] burn took 5ms, real time so far: 4840ms, cpu time so far: 273ms
2017/12/08 01:39:59 [47] burn took 5ms, real time so far: 4945ms, cpu time so far: 279ms
2017/12/08 01:39:59 [48] burn took 5ms, real time so far: 5050ms, cpu time so far: 285ms
2017/12/08 01:39:59 [49] burn took 5ms, real time so far: 5155ms, cpu time so far: 291ms
2017/12/08 01:40:00 [50] burn took 5ms, real time so far: 5261ms, cpu time so far: 296ms
2017/12/08 01:40:00 [51] burn took 5ms, real time so far: 5366ms, cpu time so far: 302ms
2017/12/08 01:40:00 [52] burn took 5ms, real time so far: 5471ms, cpu time so far: 307ms
2017/12/08 01:40:00 [53] burn took 5ms, real time so far: 5576ms, cpu time so far: 314ms
2017/12/08 01:40:00 [54] burn took 5ms, real time so far: 5681ms, cpu time so far: 320ms
2017/12/08 01:40:00 [55] burn took 5ms, real time so far: 5786ms, cpu time so far: 325ms
2017/12/08 01:40:00 [56] burn took 5ms, real time so far: 5891ms, cpu time so far: 332ms
2017/12/08 01:40:00 [57] burn took 5ms, real time so far: 5996ms, cpu time so far: 337ms
2017/12/08 01:40:00 [58] burn took 5ms, real time so far: 6101ms, cpu time so far: 343ms
2017/12/08 01:40:01 [59] burn took 5ms, real time so far: 6207ms, cpu time so far: 349ms
2017/12/08 01:40:01 [60] burn took 5ms, real time so far: 6312ms, cpu time so far: 355ms
2017/12/08 01:40:01 [61] burn took 5ms, real time so far: 6417ms, cpu time so far: 361ms
2017/12/08 01:40:01 [62] burn took 5ms, real time so far: 6522ms, cpu time so far: 366ms
2017/12/08 01:40:01 [63] burn took 5ms, real time so far: 6627ms, cpu time so far: 372ms
2017/12/08 01:40:01 [64] burn took 5ms, real time so far: 6732ms, cpu time so far: 377ms
2017/12/08 01:40:01 [65] burn took 5ms, real time so far: 6837ms, cpu time so far: 384ms
2017/12/08 01:40:01 [66] burn took 5ms, real time so far: 6942ms, cpu time so far: 389ms
2017/12/08 01:40:01 [67] burn took 5ms, real time so far: 7048ms, cpu time so far: 396ms
2017/12/08 01:40:01 [68] burn took 5ms, real time so far: 7153ms, cpu time so far: 401ms
2017/12/08 01:40:02 [69] burn took 5ms, real time so far: 7258ms, cpu time so far: 408ms
2017/12/08 01:40:02 [70] burn took 5ms, real time so far: 7363ms, cpu time so far: 414ms
2017/12/08 01:40:02 [71] burn took 5ms, real time so far: 7468ms, cpu time so far: 419ms
2017/12/08 01:40:02 [72] burn took 5ms, real time so far: 7573ms, cpu time so far: 426ms
2017/12/08 01:40:02 [73] burn took 5ms, real time so far: 7678ms, cpu time so far: 431ms
2017/12/08 01:40:02 [74] burn took 5ms, real time so far: 7783ms, cpu time so far: 437ms
2017/12/08 01:40:02 [75] burn took 5ms, real time so far: 7889ms, cpu time so far: 442ms
2017/12/08 01:40:02 [76] burn took 5ms, real time so far: 7994ms, cpu time so far: 449ms
2017/12/08 01:40:02 [77] burn took 5ms, real time so far: 8099ms, cpu time so far: 455ms
2017/12/08 01:40:03 [78] burn took 5ms, real time so far: 8204ms, cpu time so far: 460ms
2017/12/08 01:40:03 [79] burn took 5ms, real time so far: 8309ms, cpu time so far: 466ms
2017/12/08 01:40:03 [80] burn took 5ms, real time so far: 8414ms, cpu time so far: 471ms
2017/12/08 01:40:03 [81] burn took 5ms, real time so far: 8519ms, cpu time so far: 478ms
2017/12/08 01:40:03 [82] burn took 5ms, real time so far: 8624ms, cpu time so far: 483ms
2017/12/08 01:40:03 [83] burn took 5ms, real time so far: 8730ms, cpu time so far: 489ms
2017/12/08 01:40:03 [84] burn took 5ms, real time so far: 8835ms, cpu time so far: 495ms
2017/12/08 01:40:03 [85] burn took 5ms, real time so far: 8940ms, cpu time so far: 501ms
2017/12/08 01:40:03 [86] burn took 5ms, real time so far: 9045ms, cpu time so far: 507ms
2017/12/08 01:40:03 [87] burn took 5ms, real time so far: 9150ms, cpu time so far: 512ms
2017/12/08 01:40:04 [88] burn took 5ms, real time so far: 9255ms, cpu time so far: 518ms
2017/12/08 01:40:04 [89] burn took 5ms, real time so far: 9360ms, cpu time so far: 523ms
2017/12/08 01:40:04 [90] burn took 5ms, real time so far: 9465ms, cpu time so far: 529ms
2017/12/08 01:40:04 [91] burn took 5ms, real time so far: 9570ms, cpu time so far: 535ms
2017/12/08 01:40:04 [92] burn took 5ms, real time so far: 9675ms, cpu time so far: 541ms
2017/12/08 01:40:04 [93] burn took 5ms, real time so far: 9781ms, cpu time so far: 547ms
2017/12/08 01:40:04 [94] burn took 5ms, real time so far: 9886ms, cpu time so far: 552ms
2017/12/08 01:40:04 [95] burn took 5ms, real time so far: 9991ms, cpu time so far: 559ms
2017/12/08 01:40:04 [96] burn took 5ms, real time so far: 10096ms, cpu time so far: 564ms
2017/12/08 01:40:05 [97] burn took 5ms, real time so far: 10201ms, cpu time so far: 570ms
2017/12/08 01:40:05 [98] burn took 5ms, real time so far: 10306ms, cpu time so far: 575ms
2017/12/08 01:40:05 [99] burn took 5ms, real time so far: 10411ms, cpu time so far: 582ms
```

#### 1000ms sleep between iterations

Same, no throttling here.

```
$ docker run --rm -it -v $(pwd):$(pwd) -w $(pwd) golang:1.9.2 go run cfs.go -iterations 100 -sleep 1000ms
2017/12/08 01:40:42 [0] burn took 5ms, real time so far: 5ms, cpu time so far: 6ms
2017/12/08 01:40:43 [1] burn took 5ms, real time so far: 1010ms, cpu time so far: 12ms
2017/12/08 01:40:44 [2] burn took 5ms, real time so far: 2015ms, cpu time so far: 18ms
2017/12/08 01:40:45 [3] burn took 5ms, real time so far: 3020ms, cpu time so far: 24ms
2017/12/08 01:40:46 [4] burn took 5ms, real time so far: 4026ms, cpu time so far: 30ms
2017/12/08 01:40:47 [5] burn took 5ms, real time so far: 5031ms, cpu time so far: 36ms
2017/12/08 01:40:48 [6] burn took 5ms, real time so far: 6036ms, cpu time so far: 41ms
2017/12/08 01:40:49 [7] burn took 5ms, real time so far: 7041ms, cpu time so far: 47ms
2017/12/08 01:40:50 [8] burn took 5ms, real time so far: 8046ms, cpu time so far: 53ms
2017/12/08 01:40:51 [9] burn took 5ms, real time so far: 9052ms, cpu time so far: 59ms
2017/12/08 01:40:52 [10] burn took 5ms, real time so far: 10057ms, cpu time so far: 65ms
2017/12/08 01:40:53 [11] burn took 5ms, real time so far: 11062ms, cpu time so far: 71ms
2017/12/08 01:40:54 [12] burn took 5ms, real time so far: 12067ms, cpu time so far: 78ms
2017/12/08 01:40:55 [13] burn took 5ms, real time so far: 13072ms, cpu time so far: 83ms
2017/12/08 01:40:56 [14] burn took 5ms, real time so far: 14077ms, cpu time so far: 90ms
2017/12/08 01:40:57 [15] burn took 5ms, real time so far: 15083ms, cpu time so far: 95ms
2017/12/08 01:40:58 [16] burn took 5ms, real time so far: 16088ms, cpu time so far: 101ms
2017/12/08 01:40:59 [17] burn took 5ms, real time so far: 17093ms, cpu time so far: 107ms
2017/12/08 01:41:00 [18] burn took 5ms, real time so far: 18098ms, cpu time so far: 113ms
2017/12/08 01:41:01 [19] burn took 5ms, real time so far: 19103ms, cpu time so far: 119ms
2017/12/08 01:41:02 [20] burn took 5ms, real time so far: 20108ms, cpu time so far: 125ms
2017/12/08 01:41:03 [21] burn took 5ms, real time so far: 21113ms, cpu time so far: 130ms
2017/12/08 01:41:04 [22] burn took 5ms, real time so far: 22119ms, cpu time so far: 137ms
2017/12/08 01:41:05 [23] burn took 5ms, real time so far: 23124ms, cpu time so far: 143ms
2017/12/08 01:41:06 [24] burn took 5ms, real time so far: 24129ms, cpu time so far: 149ms
2017/12/08 01:41:07 [25] burn took 5ms, real time so far: 25134ms, cpu time so far: 156ms
2017/12/08 01:41:08 [26] burn took 5ms, real time so far: 26139ms, cpu time so far: 161ms
2017/12/08 01:41:09 [27] burn took 5ms, real time so far: 27144ms, cpu time so far: 167ms
2017/12/08 01:41:10 [28] burn took 5ms, real time so far: 28150ms, cpu time so far: 172ms
2017/12/08 01:41:11 [29] burn took 5ms, real time so far: 29155ms, cpu time so far: 179ms
2017/12/08 01:41:12 [30] burn took 5ms, real time so far: 30160ms, cpu time so far: 184ms
2017/12/08 01:41:13 [31] burn took 5ms, real time so far: 31165ms, cpu time so far: 191ms
2017/12/08 01:41:14 [32] burn took 5ms, real time so far: 32170ms, cpu time so far: 197ms
2017/12/08 01:41:15 [33] burn took 5ms, real time so far: 33175ms, cpu time so far: 203ms
2017/12/08 01:41:16 [34] burn took 5ms, real time so far: 34181ms, cpu time so far: 209ms
2017/12/08 01:41:17 [35] burn took 5ms, real time so far: 35186ms, cpu time so far: 214ms
2017/12/08 01:41:18 [36] burn took 5ms, real time so far: 36191ms, cpu time so far: 221ms
2017/12/08 01:41:19 [37] burn took 5ms, real time so far: 37196ms, cpu time so far: 226ms
2017/12/08 01:41:20 [38] burn took 5ms, real time so far: 38201ms, cpu time so far: 233ms
2017/12/08 01:41:21 [39] burn took 5ms, real time so far: 39206ms, cpu time so far: 238ms
2017/12/08 01:41:22 [40] burn took 5ms, real time so far: 40212ms, cpu time so far: 244ms
2017/12/08 01:41:23 [41] burn took 5ms, real time so far: 41217ms, cpu time so far: 251ms
2017/12/08 01:41:24 [42] burn took 5ms, real time so far: 42222ms, cpu time so far: 256ms
2017/12/08 01:41:25 [43] burn took 5ms, real time so far: 43227ms, cpu time so far: 263ms
2017/12/08 01:41:26 [44] burn took 5ms, real time so far: 44232ms, cpu time so far: 268ms
2017/12/08 01:41:27 [45] burn took 5ms, real time so far: 45237ms, cpu time so far: 274ms
2017/12/08 01:41:28 [46] burn took 5ms, real time so far: 46242ms, cpu time so far: 281ms
2017/12/08 01:41:29 [47] burn took 5ms, real time so far: 47248ms, cpu time so far: 286ms
2017/12/08 01:41:30 [48] burn took 5ms, real time so far: 48253ms, cpu time so far: 293ms
2017/12/08 01:41:31 [49] burn took 5ms, real time so far: 49258ms, cpu time so far: 298ms
2017/12/08 01:41:32 [50] burn took 5ms, real time so far: 50263ms, cpu time so far: 305ms
2017/12/08 01:41:33 [51] burn took 5ms, real time so far: 51268ms, cpu time so far: 310ms
2017/12/08 01:41:34 [52] burn took 5ms, real time so far: 52274ms, cpu time so far: 317ms
2017/12/08 01:41:35 [53] burn took 5ms, real time so far: 53279ms, cpu time so far: 324ms
2017/12/08 01:41:36 [54] burn took 5ms, real time so far: 54284ms, cpu time so far: 329ms
2017/12/08 01:41:37 [55] burn took 5ms, real time so far: 55289ms, cpu time so far: 336ms
2017/12/08 01:41:38 [56] burn took 5ms, real time so far: 56294ms, cpu time so far: 341ms
2017/12/08 01:41:39 [57] burn took 5ms, real time so far: 57299ms, cpu time so far: 347ms
2017/12/08 01:41:40 [58] burn took 5ms, real time so far: 58304ms, cpu time so far: 353ms
2017/12/08 01:41:41 [59] burn took 5ms, real time so far: 59310ms, cpu time so far: 359ms
2017/12/08 01:41:42 [60] burn took 5ms, real time so far: 60315ms, cpu time so far: 365ms
2017/12/08 01:41:43 [61] burn took 5ms, real time so far: 61320ms, cpu time so far: 371ms
2017/12/08 01:41:44 [62] burn took 5ms, real time so far: 62325ms, cpu time so far: 377ms
2017/12/08 01:41:45 [63] burn took 5ms, real time so far: 63330ms, cpu time so far: 382ms
2017/12/08 01:41:46 [64] burn took 5ms, real time so far: 64335ms, cpu time so far: 389ms
2017/12/08 01:41:47 [65] burn took 5ms, real time so far: 65341ms, cpu time so far: 394ms
2017/12/08 01:41:48 [66] burn took 5ms, real time so far: 66346ms, cpu time so far: 401ms
2017/12/08 01:41:49 [67] burn took 5ms, real time so far: 67351ms, cpu time so far: 408ms
2017/12/08 01:41:50 [68] burn took 5ms, real time so far: 68356ms, cpu time so far: 413ms
2017/12/08 01:41:51 [69] burn took 5ms, real time so far: 69361ms, cpu time so far: 420ms
2017/12/08 01:41:52 [70] burn took 5ms, real time so far: 70366ms, cpu time so far: 425ms
2017/12/08 01:41:53 [71] burn took 5ms, real time so far: 71371ms, cpu time so far: 432ms
2017/12/08 01:41:54 [72] burn took 5ms, real time so far: 72377ms, cpu time so far: 438ms
2017/12/08 01:41:55 [73] burn took 5ms, real time so far: 73382ms, cpu time so far: 444ms
2017/12/08 01:41:56 [74] burn took 5ms, real time so far: 74387ms, cpu time so far: 450ms
2017/12/08 01:41:57 [75] burn took 5ms, real time so far: 75392ms, cpu time so far: 456ms
2017/12/08 01:41:58 [76] burn took 5ms, real time so far: 76397ms, cpu time so far: 462ms
2017/12/08 01:41:59 [77] burn took 5ms, real time so far: 77403ms, cpu time so far: 467ms
2017/12/08 01:42:00 [78] burn took 5ms, real time so far: 78408ms, cpu time so far: 474ms
2017/12/08 01:42:01 [79] burn took 5ms, real time so far: 79413ms, cpu time so far: 479ms
2017/12/08 01:42:02 [80] burn took 5ms, real time so far: 80418ms, cpu time so far: 486ms
2017/12/08 01:42:03 [81] burn took 5ms, real time so far: 81423ms, cpu time so far: 492ms
2017/12/08 01:42:04 [82] burn took 5ms, real time so far: 82428ms, cpu time so far: 498ms
2017/12/08 01:42:05 [83] burn took 5ms, real time so far: 83434ms, cpu time so far: 505ms
2017/12/08 01:42:06 [84] burn took 5ms, real time so far: 84439ms, cpu time so far: 510ms
2017/12/08 01:42:07 [85] burn took 5ms, real time so far: 85444ms, cpu time so far: 516ms
2017/12/08 01:42:08 [86] burn took 5ms, real time so far: 86449ms, cpu time so far: 522ms
2017/12/08 01:42:09 [87] burn took 5ms, real time so far: 87454ms, cpu time so far: 528ms
2017/12/08 01:42:10 [88] burn took 5ms, real time so far: 88460ms, cpu time so far: 535ms
2017/12/08 01:42:11 [89] burn took 5ms, real time so far: 89465ms, cpu time so far: 540ms
2017/12/08 01:42:12 [90] burn took 5ms, real time so far: 90470ms, cpu time so far: 547ms
2017/12/08 01:42:13 [91] burn took 5ms, real time so far: 91475ms, cpu time so far: 552ms
2017/12/08 01:42:14 [92] burn took 5ms, real time so far: 92480ms, cpu time so far: 559ms
2017/12/08 01:42:15 [93] burn took 5ms, real time so far: 93485ms, cpu time so far: 564ms
2017/12/08 01:42:16 [94] burn took 5ms, real time so far: 94490ms, cpu time so far: 570ms
2017/12/08 01:42:17 [95] burn took 5ms, real time so far: 95496ms, cpu time so far: 576ms
2017/12/08 01:42:18 [96] burn took 5ms, real time so far: 96501ms, cpu time so far: 582ms
2017/12/08 01:42:19 [97] burn took 5ms, real time so far: 97506ms, cpu time so far: 588ms
2017/12/08 01:42:20 [98] burn took 5ms, real time so far: 98511ms, cpu time so far: 594ms
2017/12/08 01:42:21 [99] burn took 5ms, real time so far: 99516ms, cpu time so far: 600ms
```

## Running with throttling

This is where things get interesting. We set cfs quota to 20ms and cfs period
to 100ms, so we can use at most 20% of cpu during any 100ms period. If we ever
go over 20ms of cpu time, we'll be throttled for the remaining of 100ms period.

#### 100ms sleep between iterations

We burn CPU for 5ms and then we sleep for 100ms, that sums up to 105ms,
so in theory we should never go over quota. In practice, we see throttles
from time to time.

```
$ docker run --rm -it --cpu-quota 20000 --cpu-period 100000 -v $(pwd):$(pwd) -w $(pwd) golang:1.9.2 go run cfs.go -iterations 100 -sleep 100ms
2017/12/08 01:42:50 [0] burn took 5ms, real time so far: 5ms, cpu time so far: 6ms
2017/12/08 01:42:50 [1] burn took 5ms, real time so far: 194ms, cpu time so far: 12ms
2017/12/08 01:42:50 [2] burn took 5ms, real time so far: 299ms, cpu time so far: 18ms
2017/12/08 01:42:50 [3] burn took 5ms, real time so far: 404ms, cpu time so far: 23ms
2017/12/08 01:42:51 [4] burn took 5ms, real time so far: 509ms, cpu time so far: 29ms
2017/12/08 01:42:51 [5] burn took 5ms, real time so far: 614ms, cpu time so far: 35ms
2017/12/08 01:42:51 [6] burn took 5ms, real time so far: 719ms, cpu time so far: 40ms
2017/12/08 01:42:51 [7] burn took 5ms, real time so far: 824ms, cpu time so far: 46ms
2017/12/08 01:42:51 [8] burn took 5ms, real time so far: 930ms, cpu time so far: 51ms
2017/12/08 01:42:51 [9] burn took 5ms, real time so far: 1035ms, cpu time so far: 58ms
2017/12/08 01:42:51 [10] burn took 5ms, real time so far: 1140ms, cpu time so far: 64ms
2017/12/08 01:42:51 [11] burn took 5ms, real time so far: 1245ms, cpu time so far: 69ms
2017/12/08 01:42:51 [12] burn took 5ms, real time so far: 1350ms, cpu time so far: 75ms
2017/12/08 01:42:51 [13] burn took 5ms, real time so far: 1455ms, cpu time so far: 81ms
2017/12/08 01:42:52 [14] burn took 5ms, real time so far: 1560ms, cpu time so far: 87ms
2017/12/08 01:42:52 [15] burn took 5ms, real time so far: 1665ms, cpu time so far: 92ms
2017/12/08 01:42:52 [16] burn took 5ms, real time so far: 1770ms, cpu time so far: 98ms
2017/12/08 01:42:52 [17] burn took 5ms, real time so far: 1876ms, cpu time so far: 105ms
2017/12/08 01:42:52 [18] burn took 5ms, real time so far: 1981ms, cpu time so far: 110ms
2017/12/08 01:42:52 [19] burn took 5ms, real time so far: 2086ms, cpu time so far: 117ms
2017/12/08 01:42:52 [20] burn took 5ms, real time so far: 2191ms, cpu time so far: 122ms
2017/12/08 01:42:52 [21] burn took 97ms, real time so far: 2389ms, cpu time so far: 127ms
2017/12/08 01:42:53 [22] burn took 5ms, real time so far: 2494ms, cpu time so far: 133ms
2017/12/08 01:42:53 [23] burn took 5ms, real time so far: 2599ms, cpu time so far: 140ms
2017/12/08 01:42:53 [24] burn took 5ms, real time so far: 2704ms, cpu time so far: 145ms
2017/12/08 01:42:53 [25] burn took 5ms, real time so far: 2809ms, cpu time so far: 152ms
2017/12/08 01:42:53 [26] burn took 5ms, real time so far: 2914ms, cpu time so far: 157ms
2017/12/08 01:42:53 [27] burn took 5ms, real time so far: 3019ms, cpu time so far: 164ms
2017/12/08 01:42:53 [28] burn took 5ms, real time so far: 3125ms, cpu time so far: 170ms
2017/12/08 01:42:53 [29] burn took 5ms, real time so far: 3230ms, cpu time so far: 175ms
2017/12/08 01:42:53 [30] burn took 5ms, real time so far: 3335ms, cpu time so far: 182ms
2017/12/08 01:42:53 [31] burn took 5ms, real time so far: 3440ms, cpu time so far: 187ms
2017/12/08 01:42:54 [32] burn took 5ms, real time so far: 3545ms, cpu time so far: 193ms
2017/12/08 01:42:54 [33] burn took 5ms, real time so far: 3650ms, cpu time so far: 198ms
2017/12/08 01:42:54 [34] burn took 5ms, real time so far: 3755ms, cpu time so far: 205ms
2017/12/08 01:42:54 [35] burn took 5ms, real time so far: 3860ms, cpu time so far: 211ms
2017/12/08 01:42:54 [36] burn took 5ms, real time so far: 3965ms, cpu time so far: 216ms
2017/12/08 01:42:54 [37] burn took 5ms, real time so far: 4071ms, cpu time so far: 222ms
2017/12/08 01:42:54 [38] burn took 5ms, real time so far: 4176ms, cpu time so far: 228ms
2017/12/08 01:42:54 [39] burn took 5ms, real time so far: 4281ms, cpu time so far: 234ms
2017/12/08 01:42:54 [40] burn took 5ms, real time so far: 4386ms, cpu time so far: 239ms
2017/12/08 01:42:55 [41] burn took 5ms, real time so far: 4491ms, cpu time so far: 246ms
2017/12/08 01:42:55 [42] burn took 97ms, real time so far: 4689ms, cpu time so far: 252ms
2017/12/08 01:42:55 [43] burn took 5ms, real time so far: 4794ms, cpu time so far: 257ms
2017/12/08 01:42:55 [44] burn took 5ms, real time so far: 4899ms, cpu time so far: 264ms
2017/12/08 01:42:55 [45] burn took 5ms, real time so far: 5004ms, cpu time so far: 269ms
2017/12/08 01:42:55 [46] burn took 5ms, real time so far: 5109ms, cpu time so far: 275ms
2017/12/08 01:42:55 [47] burn took 5ms, real time so far: 5214ms, cpu time so far: 281ms
2017/12/08 01:42:55 [48] burn took 5ms, real time so far: 5320ms, cpu time so far: 287ms
2017/12/08 01:42:55 [49] burn took 5ms, real time so far: 5425ms, cpu time so far: 292ms
2017/12/08 01:42:56 [50] burn took 5ms, real time so far: 5530ms, cpu time so far: 298ms
2017/12/08 01:42:56 [51] burn took 5ms, real time so far: 5635ms, cpu time so far: 305ms
2017/12/08 01:42:56 [52] burn took 5ms, real time so far: 5740ms, cpu time so far: 310ms
2017/12/08 01:42:56 [53] burn took 5ms, real time so far: 5845ms, cpu time so far: 316ms
2017/12/08 01:42:56 [54] burn took 5ms, real time so far: 5950ms, cpu time so far: 321ms
2017/12/08 01:42:56 [55] burn took 5ms, real time so far: 6055ms, cpu time so far: 328ms
2017/12/08 01:42:56 [56] burn took 5ms, real time so far: 6161ms, cpu time so far: 333ms
2017/12/08 01:42:56 [57] burn took 5ms, real time so far: 6266ms, cpu time so far: 339ms
2017/12/08 01:42:56 [58] burn took 5ms, real time so far: 6371ms, cpu time so far: 345ms
2017/12/08 01:42:56 [59] burn took 5ms, real time so far: 6476ms, cpu time so far: 351ms
2017/12/08 01:42:57 [60] burn took 5ms, real time so far: 6581ms, cpu time so far: 357ms
2017/12/08 01:42:57 [61] burn took 5ms, real time so far: 6686ms, cpu time so far: 362ms
2017/12/08 01:42:57 [62] burn took 5ms, real time so far: 6791ms, cpu time so far: 368ms
2017/12/08 01:42:57 [63] burn took 5ms, real time so far: 6896ms, cpu time so far: 374ms
2017/12/08 01:42:57 [64] burn took 5ms, real time so far: 7001ms, cpu time so far: 380ms
2017/12/08 01:42:57 [65] burn took 5ms, real time so far: 7107ms, cpu time so far: 386ms
2017/12/08 01:42:57 [66] burn took 5ms, real time so far: 7212ms, cpu time so far: 392ms
2017/12/08 01:42:57 [67] burn took 5ms, real time so far: 7317ms, cpu time so far: 398ms
2017/12/08 01:42:57 [68] burn took 5ms, real time so far: 7422ms, cpu time so far: 403ms
2017/12/08 01:42:58 [69] burn took 5ms, real time so far: 7527ms, cpu time so far: 410ms
2017/12/08 01:42:58 [70] burn took 5ms, real time so far: 7632ms, cpu time so far: 415ms
2017/12/08 01:42:58 [71] burn took 5ms, real time so far: 7737ms, cpu time so far: 421ms
2017/12/08 01:42:58 [72] burn took 5ms, real time so far: 7842ms, cpu time so far: 427ms
2017/12/08 01:42:58 [73] burn took 5ms, real time so far: 7947ms, cpu time so far: 432ms
2017/12/08 01:42:58 [74] burn took 5ms, real time so far: 8053ms, cpu time so far: 439ms
2017/12/08 01:42:58 [75] burn took 5ms, real time so far: 8158ms, cpu time so far: 444ms
2017/12/08 01:42:58 [76] burn took 5ms, real time so far: 8263ms, cpu time so far: 450ms
2017/12/08 01:42:58 [77] burn took 5ms, real time so far: 8368ms, cpu time so far: 455ms
2017/12/08 01:42:58 [78] burn took 5ms, real time so far: 8473ms, cpu time so far: 461ms
2017/12/08 01:42:59 [79] burn took 5ms, real time so far: 8578ms, cpu time so far: 468ms
2017/12/08 01:42:59 [80] burn took 5ms, real time so far: 8683ms, cpu time so far: 473ms
2017/12/08 01:42:59 [81] burn took 5ms, real time so far: 8788ms, cpu time so far: 479ms
2017/12/08 01:42:59 [82] burn took 5ms, real time so far: 8894ms, cpu time so far: 484ms
2017/12/08 01:42:59 [83] burn took 5ms, real time so far: 9094ms, cpu time so far: 491ms
2017/12/08 01:42:59 [84] burn took 5ms, real time so far: 9199ms, cpu time so far: 497ms
2017/12/08 01:42:59 [85] burn took 5ms, real time so far: 9304ms, cpu time so far: 502ms
2017/12/08 01:42:59 [86] burn took 5ms, real time so far: 9409ms, cpu time so far: 508ms
2017/12/08 01:43:00 [87] burn took 5ms, real time so far: 9514ms, cpu time so far: 514ms
2017/12/08 01:43:00 [88] burn took 5ms, real time so far: 9619ms, cpu time so far: 520ms
2017/12/08 01:43:00 [89] burn took 5ms, real time so far: 9724ms, cpu time so far: 525ms
2017/12/08 01:43:00 [90] burn took 5ms, real time so far: 9829ms, cpu time so far: 531ms
2017/12/08 01:43:00 [91] burn took 5ms, real time so far: 9935ms, cpu time so far: 538ms
2017/12/08 01:43:00 [92] burn took 5ms, real time so far: 10040ms, cpu time so far: 543ms
2017/12/08 01:43:00 [93] burn took 5ms, real time so far: 10145ms, cpu time so far: 550ms
2017/12/08 01:43:00 [94] burn took 5ms, real time so far: 10250ms, cpu time so far: 555ms
2017/12/08 01:43:00 [95] burn took 5ms, real time so far: 10355ms, cpu time so far: 561ms
2017/12/08 01:43:00 [96] burn took 5ms, real time so far: 10460ms, cpu time so far: 566ms
2017/12/08 01:43:01 [97] burn took 5ms, real time so far: 10565ms, cpu time so far: 573ms
2017/12/08 01:43:01 [98] burn took 5ms, real time so far: 10670ms, cpu time so far: 578ms
2017/12/08 01:43:01 [99] burn took 5ms, real time so far: 10776ms, cpu time so far: 585ms
```

#### 1000ms sleep between iterations

With 5ms burns and 1000ms sleeps between them there are no 100ms intervals
during which we can possibly see 20ms burned on CPU to get throttled. However,
we see lots of throttling here. Almost every burn is throttled.

```
$ docker run --rm -it --cpu-quota 20000 --cpu-period 100000 -v $(pwd):$(pwd) -w $(pwd) golang:1.9.2 go run cfs.go -iterations 100 -sleep 1000ms
2017/12/08 01:44:27 [0] burn took 5ms, real time so far: 5ms, cpu time so far: 6ms
2017/12/08 01:44:28 [1] burn took 100ms, real time so far: 1187ms, cpu time so far: 12ms
2017/12/08 01:44:30 [2] burn took 5ms, real time so far: 2192ms, cpu time so far: 18ms
2017/12/08 01:44:31 [3] burn took 99ms, real time so far: 3386ms, cpu time so far: 25ms
2017/12/08 01:44:32 [4] burn took 5ms, real time so far: 4391ms, cpu time so far: 30ms
2017/12/08 01:44:33 [5] burn took 100ms, real time so far: 5586ms, cpu time so far: 35ms
2017/12/08 01:44:34 [6] burn took 99ms, real time so far: 6686ms, cpu time so far: 40ms
2017/12/08 01:44:35 [7] burn took 5ms, real time so far: 7691ms, cpu time so far: 45ms
2017/12/08 01:44:36 [8] burn took 99ms, real time so far: 8886ms, cpu time so far: 52ms
2017/12/08 01:44:37 [9] burn took 99ms, real time so far: 9986ms, cpu time so far: 58ms
2017/12/08 01:44:38 [10] burn took 5ms, real time so far: 10991ms, cpu time so far: 64ms
2017/12/08 01:44:39 [11] burn took 99ms, real time so far: 12186ms, cpu time so far: 69ms
2017/12/08 01:44:41 [12] burn took 5ms, real time so far: 13191ms, cpu time so far: 75ms
2017/12/08 01:44:42 [13] burn took 99ms, real time so far: 14386ms, cpu time so far: 80ms
2017/12/08 01:44:43 [14] burn took 99ms, real time so far: 15486ms, cpu time so far: 86ms
2017/12/08 01:44:44 [15] burn took 100ms, real time so far: 16586ms, cpu time so far: 93ms
2017/12/08 01:44:45 [16] burn took 5ms, real time so far: 17591ms, cpu time so far: 99ms
2017/12/08 01:44:46 [17] burn took 99ms, real time so far: 18786ms, cpu time so far: 101ms
2017/12/08 01:44:47 [18] burn took 99ms, real time so far: 19886ms, cpu time so far: 104ms
2017/12/08 01:44:48 [19] burn took 5ms, real time so far: 20891ms, cpu time so far: 109ms
2017/12/08 01:44:49 [20] burn took 100ms, real time so far: 22086ms, cpu time so far: 115ms
2017/12/08 01:44:50 [21] burn took 99ms, real time so far: 23186ms, cpu time so far: 120ms
2017/12/08 01:44:52 [22] burn took 99ms, real time so far: 24286ms, cpu time so far: 126ms
2017/12/08 01:44:53 [23] burn took 5ms, real time so far: 25291ms, cpu time so far: 132ms
2017/12/08 01:44:54 [24] burn took 99ms, real time so far: 26486ms, cpu time so far: 137ms
2017/12/08 01:44:55 [25] burn took 5ms, real time so far: 27491ms, cpu time so far: 143ms
2017/12/08 01:44:56 [26] burn took 99ms, real time so far: 28686ms, cpu time so far: 150ms
2017/12/08 01:44:57 [27] burn took 5ms, real time so far: 29691ms, cpu time so far: 155ms
2017/12/08 01:44:58 [28] burn took 100ms, real time so far: 30886ms, cpu time so far: 160ms
2017/12/08 01:44:59 [29] burn took 5ms, real time so far: 31891ms, cpu time so far: 166ms
2017/12/08 01:45:00 [30] burn took 99ms, real time so far: 33086ms, cpu time so far: 170ms
2017/12/08 01:45:01 [31] burn took 99ms, real time so far: 34186ms, cpu time so far: 176ms
2017/12/08 01:45:03 [32] burn took 99ms, real time so far: 35286ms, cpu time so far: 182ms
2017/12/08 01:45:04 [33] burn took 5ms, real time so far: 36291ms, cpu time so far: 187ms
2017/12/08 01:45:05 [34] burn took 99ms, real time so far: 37486ms, cpu time so far: 192ms
2017/12/08 01:45:06 [35] burn took 99ms, real time so far: 38586ms, cpu time so far: 197ms
2017/12/08 01:45:07 [36] burn took 99ms, real time so far: 39686ms, cpu time so far: 202ms
2017/12/08 01:45:08 [37] burn took 5ms, real time so far: 40691ms, cpu time so far: 208ms
2017/12/08 01:45:09 [38] burn took 99ms, real time so far: 41886ms, cpu time so far: 213ms
2017/12/08 01:45:10 [39] burn took 99ms, real time so far: 42986ms, cpu time so far: 219ms
2017/12/08 01:45:11 [40] burn took 99ms, real time so far: 44086ms, cpu time so far: 224ms
2017/12/08 01:45:12 [41] burn took 99ms, real time so far: 45186ms, cpu time so far: 229ms
2017/12/08 01:45:14 [42] burn took 99ms, real time so far: 46286ms, cpu time so far: 235ms
2017/12/08 01:45:15 [43] burn took 99ms, real time so far: 47386ms, cpu time so far: 241ms
2017/12/08 01:45:16 [44] burn took 100ms, real time so far: 48486ms, cpu time so far: 247ms
2017/12/08 01:45:17 [45] burn took 99ms, real time so far: 49586ms, cpu time so far: 253ms
2017/12/08 01:45:18 [46] burn took 99ms, real time so far: 50686ms, cpu time so far: 259ms
2017/12/08 01:45:19 [47] burn took 5ms, real time so far: 51691ms, cpu time so far: 265ms
2017/12/08 01:45:20 [48] burn took 99ms, real time so far: 52886ms, cpu time so far: 270ms
2017/12/08 01:45:21 [49] burn took 5ms, real time so far: 53891ms, cpu time so far: 276ms
2017/12/08 01:45:22 [50] burn took 99ms, real time so far: 55086ms, cpu time so far: 281ms
2017/12/08 01:45:23 [51] burn took 99ms, real time so far: 56186ms, cpu time so far: 286ms
2017/12/08 01:45:25 [52] burn took 99ms, real time so far: 57286ms, cpu time so far: 292ms
2017/12/08 01:45:26 [53] burn took 5ms, real time so far: 58291ms, cpu time so far: 298ms
2017/12/08 01:45:27 [54] burn took 99ms, real time so far: 59486ms, cpu time so far: 303ms
2017/12/08 01:45:28 [55] burn took 5ms, real time so far: 60491ms, cpu time so far: 309ms
2017/12/08 01:45:29 [56] burn took 99ms, real time so far: 61686ms, cpu time so far: 314ms
2017/12/08 01:45:30 [57] burn took 5ms, real time so far: 62691ms, cpu time so far: 320ms
2017/12/08 01:45:31 [58] burn took 100ms, real time so far: 63886ms, cpu time so far: 326ms
2017/12/08 01:45:32 [59] burn took 99ms, real time so far: 64986ms, cpu time so far: 328ms
2017/12/08 01:45:33 [60] burn took 5ms, real time so far: 65991ms, cpu time so far: 333ms
2017/12/08 01:45:34 [61] burn took 99ms, real time so far: 67186ms, cpu time so far: 337ms
2017/12/08 01:45:36 [62] burn took 5ms, real time so far: 68191ms, cpu time so far: 343ms
2017/12/08 01:45:37 [63] burn took 100ms, real time so far: 69386ms, cpu time so far: 350ms
2017/12/08 01:45:38 [64] burn took 99ms, real time so far: 70486ms, cpu time so far: 355ms
2017/12/08 01:45:39 [65] burn took 100ms, real time so far: 71586ms, cpu time so far: 361ms
2017/12/08 01:45:40 [66] burn took 5ms, real time so far: 72591ms, cpu time so far: 367ms
2017/12/08 01:45:41 [67] burn took 5ms, real time so far: 73691ms, cpu time so far: 374ms
2017/12/08 01:45:42 [68] burn took 94ms, real time so far: 74786ms, cpu time so far: 379ms
2017/12/08 01:45:43 [69] burn took 99ms, real time so far: 75886ms, cpu time so far: 385ms
2017/12/08 01:45:44 [70] burn took 5ms, real time so far: 76891ms, cpu time so far: 390ms
2017/12/08 01:45:45 [71] burn took 99ms, real time so far: 78086ms, cpu time so far: 395ms
2017/12/08 01:45:46 [72] burn took 99ms, real time so far: 79186ms, cpu time so far: 396ms
2017/12/08 01:45:48 [73] burn took 5ms, real time so far: 80191ms, cpu time so far: 401ms
2017/12/08 01:45:49 [74] burn took 99ms, real time so far: 81386ms, cpu time so far: 406ms
2017/12/08 01:45:50 [75] burn took 5ms, real time so far: 82391ms, cpu time so far: 412ms
2017/12/08 01:45:51 [76] burn took 99ms, real time so far: 83586ms, cpu time so far: 417ms
2017/12/08 01:45:52 [77] burn took 5ms, real time so far: 84591ms, cpu time so far: 423ms
2017/12/08 01:45:53 [78] burn took 99ms, real time so far: 85786ms, cpu time so far: 429ms
2017/12/08 01:45:54 [79] burn took 5ms, real time so far: 86791ms, cpu time so far: 434ms
2017/12/08 01:45:55 [80] burn took 100ms, real time so far: 87986ms, cpu time so far: 440ms
2017/12/08 01:45:56 [81] burn took 99ms, real time so far: 89086ms, cpu time so far: 446ms
2017/12/08 01:45:57 [82] burn took 99ms, real time so far: 90186ms, cpu time so far: 448ms
2017/12/08 01:45:59 [83] burn took 99ms, real time so far: 91286ms, cpu time so far: 452ms
2017/12/08 01:46:00 [84] burn took 99ms, real time so far: 92386ms, cpu time so far: 457ms
2017/12/08 01:46:01 [85] burn took 99ms, real time so far: 93486ms, cpu time so far: 463ms
2017/12/08 01:46:02 [86] burn took 5ms, real time so far: 94491ms, cpu time so far: 468ms
2017/12/08 01:46:03 [87] burn took 99ms, real time so far: 95686ms, cpu time so far: 474ms
2017/12/08 01:46:04 [88] burn took 5ms, real time so far: 96691ms, cpu time so far: 480ms
2017/12/08 01:46:05 [89] burn took 99ms, real time so far: 97886ms, cpu time so far: 486ms
2017/12/08 01:46:06 [90] burn took 5ms, real time so far: 98891ms, cpu time so far: 492ms
2017/12/08 01:46:07 [91] burn took 100ms, real time so far: 100086ms, cpu time so far: 497ms
2017/12/08 01:46:08 [92] burn took 5ms, real time so far: 101091ms, cpu time so far: 503ms
2017/12/08 01:46:10 [93] burn took 99ms, real time so far: 102286ms, cpu time so far: 508ms
2017/12/08 01:46:11 [94] burn took 5ms, real time so far: 103291ms, cpu time so far: 514ms
2017/12/08 01:46:12 [95] burn took 99ms, real time so far: 104486ms, cpu time so far: 518ms
2017/12/08 01:46:13 [96] burn took 99ms, real time so far: 105586ms, cpu time so far: 525ms
2017/12/08 01:46:14 [97] burn took 99ms, real time so far: 106686ms, cpu time so far: 529ms
2017/12/08 01:46:15 [98] burn took 99ms, real time so far: 107786ms, cpu time so far: 532ms
2017/12/08 01:46:16 [99] burn took 5ms, real time so far: 108791ms, cpu time so far: 538ms
```

### 5000ms sleep between iterations

Again, lots of unexpected throttling.

```
$ docker run --rm -it --cpu-quota 20000 --cpu-period 100000 -v $(pwd):$(pwd) -w $(pwd) golang:1.9.2 go run cfs.go -iterations 10 -sleep 5000ms
2017/12/08 01:46:45 [0] burn took 5ms, real time so far: 5ms, cpu time so far: 6ms
2017/12/08 01:46:50 [1] burn took 100ms, real time so far: 5199ms, cpu time so far: 12ms
2017/12/08 01:46:55 [2] burn took 98ms, real time so far: 10298ms, cpu time so far: 15ms
2017/12/08 01:47:00 [3] burn took 5ms, real time so far: 15303ms, cpu time so far: 20ms
2017/12/08 01:47:05 [4] burn took 99ms, real time so far: 20498ms, cpu time so far: 26ms
2017/12/08 01:47:10 [5] burn took 99ms, real time so far: 25598ms, cpu time so far: 31ms
2017/12/08 01:47:15 [6] burn took 99ms, real time so far: 30698ms, cpu time so far: 38ms
2017/12/08 01:47:20 [7] burn took 99ms, real time so far: 35798ms, cpu time so far: 44ms
2017/12/08 01:47:25 [8] burn took 99ms, real time so far: 40898ms, cpu time so far: 49ms
2017/12/08 01:47:30 [9] burn took 99ms, real time so far: 45998ms, cpu time so far: 55ms
```
