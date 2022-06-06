# Platform Engineer Hiring Project

Hello! This is a hiring project for our [Platform Engineer position](https://fly.io/jobs/platform-product-engineer/). If you apply, we'll ask you to do this project so we can see how you work through a contrived (yet shockingly accurate) example of the type of things you'd do at Fly.io.

## The Job 

As a Platform Engineer at Fly.io, you'll be working on the product we sell to customers and the infrastructure needed to operate it. Checkout the [job post](https://fly.io/jobs/platform-product-engineer/) for the nitty gritty.

## Hiring Project

The most significant software component in Fly.io’s architecture is our `fly-proxy`, which is implemented in Rust with Tokio. `fly-proxy` drives our Anycast network: practically all traffic for apps running on Fly.io flows through the proxy. Some of the things it does include:
- Automatically handling LetsEncrypt ALPN certificate issuance for apps and transparently terminating TLS, so apps come up the first time with a solid TLS configuration.
- Routing HTTP/1.1 and HTTP2 traffic from our edge to customer VMs, with per-customer concurrency isolation.
- Coalescing HTTP/1.1 requests received on our edge into multiplexed HTTP2 sessions to our worker servers.
- Generating fine-grained Prometheus metrics for customer applications.
- Routing WebSockets connections to VMs transparently.
- Forwarding raw TCP connections for non-web applications.

What we’d like you to do for this coding challenge is to implement your own version of this proxy, so we can see how you’d do it if you were in our shoes.

OBVIOUSLY WE ARE KIDDING.

What we want you to write is just the last bullet point from that feature list: a configurable raw TCP proxy, using the Go net package. Work will be split up into two parts.

### Part 1 - Configurable TCP proxy

First up, you're going to build a raw TCP proxy using the standard `net` Go package. Just like the real `fly-proxy`, yours will be configured with multiple apps, each with potentially many backend targets. There's already a `config` package that handles loading and watching a `config.json` file. Checkout the `config.json` file to see what needs to be supported. 

Criteria
- We can run your code with `go run`
- It listens on each port listed in the config file. Connections to any of those ports routes to one of the correct app's targets.
- If an app has multiple targets, you should have a sensible way of balancing between targets.
- If the target you've chosen is unavailable for whatever reason, the connection should still work if there are multiple targets available.

Along with your code, include a `NOTES.md` that goes over:
- A short summary of what you built, how it works, and how you landed on this design
- How you might add hot config reloading that doesn't break existing connections if apps and targets change
- What might break under a production load? What needs to happen before your proxy is production ready?
- If this were deployed to production at Fly.io, is there anything you could do with your proxy that would make our customers happy?
- If you were starting over, is there anything you'd do differently?
- How would you make a global, clustered version of your proxy?

### Part 2 - BPF Steering

Not long ago, `fly-proxy` would only listen on a small list of ports, just like your proxy does now. We added more ports when customers asked, but the amount of work was non-trivial, and the strict list of supported ports was annoying customers. Our solution was using an `sk_lookup` BPF program that would route TCP connections for Anycast addresses to `fly-proxy`'s listener. 

For the second part of this challenge, you'll be adding a similar BPF socket-steering program to your proxy so that any number of ports provided in your configuration can be routed to a single listener socket.

Most people we talk to haven’t done any significant BPF work, and we don’t expect you to have either. Don't worry, it's simpler than you think. Checkout the [BPF notes](BPF.md) to get started.

Criteria
- A BPF program that routes connections on any configured port to your proxy's listener.
- Your proxy still maps inbound connections to the correct app and forwards to a target.
- Your BPF code can be built with scripts or a Makefile
- Your BPF code can be configured and managed with scripts or by your Go program
- You've documented how to build and run your BPF code.

Update the `NOTES.md` file from Part 1 to cover:
- what you did to add BPF steering
- how you'd update the BPF maps when configuration changes

## What we care about

- The basic proxy needs to work.
- Even though you may be new to BPF, you're able to figure out enough to make it work.
- Your code should be clear and idiomatic.
- It's okay to deliver complicated features as written notes rather than code, but if you're able to bang them out, go for it.
- Don't spend time making this perfect. Rough edges are fine if it helps you move quickly. It's okay to skip the last 20% to make it production ready, but you should know what that 20% is and explain it in the notes.
- Don't spend time on tests for this project.
- Don't skimp on the notes. Code is important, but understanding your thought process is far more insightful.

## Submitting your work

We'll invite you to a private GitHub repo based on this template. Do all of your work in the `main` branch. We only care about the end result, no need to preserve the non-BPF implementation. Don't bother with PRs, branches, or spend time on tidy commits -- we have software to help us review. Just don't force push over the initial commit or we can't generate a diff of only your work. When you're ready, let us know and we'll schedule it for review. We review submissions once a week. You'll hear back from us no matter what by the end of the _following_ week, possibly sooner if you submit early in the week.

Let us know what email address you registered with Fly and we'll give you some credits so you can play around or launch a dev environment.

## Tips and Tricks

- You can use our test echo server for app backends: https://tcp-echo.fly.dev 
- You can use netcat to test your proxy `echo "hello" | nc -N -4 localhost 6300`
- You can run a dev server on Fly.io if you don't have access to a Linux machine for the eBPF part.

Have fun!
