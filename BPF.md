# BPF Notes

We don't want you spinning your wheels, so if this isn't enough to get you unstuck, come back to us! It was annoying for us to get this working, and we're happy to spare you the worst of that.

### Prerequesites:

You'll need a Linux host running kernel >= 5.9 (when they introduced sk_lookup) to build and run your BPF program. Linux in Docker on an M1 Mac will _not_ work. WSL2 on Windows or Docker on Intel macs might work, though we haven't tried. If you don't have access to a Linux box and can't run a VM you can spin up a dev VM on Fly.

You'll need the following tools and libraries installed:
  - `bpftool` compiled for a >= 5.9 kernel, because pre-5.9 `bpftool` doesn't know what an sk_lookup program is.
  - `libbpf` source code, which you can get from Github, because it has a recent `bpf_helper_defs.h` with `bpf_sk_assign` in it, which you need to make this program work.
  - clang>10 to generate ELF .o's that new bpftool will load from.

If you're using something like Ubuntu, the `bpftool` and `libppf-dev` packages aren't compiled for the right version before 21.01. In this case you'll need to build and install from kernel sources. 

### Fly.io Dev Server

This repo also contains source for a VS Code remote dev server. To run it,

- `flyctl launch`
- `flyctl volumes create data`
- `flyctl secrets set ROOT_PASSWORD=<somethingsecret>`
- `flyctl deploy`

Once your VM is deployed, you should be able to access it at `ssh://root:<somethingsecret>@yourapp.fly.dev:2222`. Follow [these docs](https://code.visualstudio.com/docs/remote/ssh) to connect to it from VS Code on your machine, pull down your code from GitHub, and move on with the fun part.

### Starting points:

- Check out this presentation: https://ebpf.io/summit-2020-slides/eBPF_Summit_2020-Lightning-Jakub_Sitnicki-Steering_connections_to_sockets_with_BPF_socke_lookup_hook.pdf
- Interacting with eBPF from Go: 

### 

There are exotic ways to build BPF programs. Those are fine if you'd like, but C code complied with clang works just fine. Here's an example Makefile:

```
CC= clang-11
CFLAGS= -O2 -target bpf

proxy_dispatch.o: proxy_dispatch.c
$(CC) -I/usr/local/include $(CFLAGS) -c $(<) -o $(@)
```

Then you can load the program with:

```
$ sudo bpftool prog load ./bpf/proxy_dispatch.bpf.o /sys/fs/bpf/proxy_dispatch_prog
```

and verify that it was loaded with:

```
$ bpftool prog show pinned /sys/fs/bpf/proxy_dispatch_prog
120: sk_lookup  name proxy_dispatch  tag da043673afd29081  gpl
        loaded_at 2022-03-03T00:21:03+0000  uid 0
        xlated 272B  jited 155B  memlock 4096B  map_ids 4,5
```

The goal of the sk_lookup hook is to assign incoming connections to sockets. You tell the BPF program which socket to attach to with a `BPF_MAP_TYPE_SOCKMAP` map, which for you will be a 1-entry map, keys `uint32_t`, values `uint64_t`. You'll tell the BPF program which ports are open with a `BPF_MAP_TYPE_HASH` map with `uint16_t` keys for ports, and empty `uint8_t` for the value. 

When your target program loads, you'll want it to:
1. load the BPF `BPF_MAP_TYPE_SOCKMAP`
2. get the fd of the listening socket
3. put the fd in the map at key=0
4. load the BPF `BPF_MAP_TYPE_HASH`
5. put each port in at `[port]=0`
6. open /proc/self/ns/net and get the fd
7. open your BPF program (the "prog load" line above has the path)
8. attach the program to the netns fd

Whatever your BPF program does, at this point it should be running. Note that doing this all from `bpftool` is fine for poking around, but you may want to have your go program handle it for you. Especially so you're proxy can support hot config reloads. There's many ways to do this, from shelling out to `bpftool` or a go package like https://github.com/cilium/ebpf. The implementation is up to you!

You can `bpf_trace_printk` and `cat /sys/kernel/debug/tracing/trace_pipe` to print-debug your BPF program. Just remember the fmt argument you pass to trace_printk has to be on the stack --- so, `char fmt[] = "my fmt string";`, not `char *fmt = "my fmt string";`.
