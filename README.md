
# Platform Engineer Hiring Project
Hello! This is a hiring project for our  [Platform Engineer position](https://fly.io/jobs/platform-product-engineer/) . If you apply, we’ll ask you to do this project so we can see how you work through a contrived (yet shockingly accurate) example of the type of things you’d do at Fly.io.

# The Job
As a Platform Engineer at Fly.io, you’ll be working on the product we sell to customers and the infrastructure needed to operate it. Checkout the  [job post](https://fly.io/jobs/platform-product-engineer/)  for the nitty gritty.

# Hiring Project
The most significant software component in Fly.io’s architecture is `fly-proxy`.`fly-proxy` drives our Anycast network. When a user in Tokyo makes an HTTP request for a Fly.io app running in Frankfurt, they’re talking to a Tokyo instance of `fly-proxy`, which finds a matching `fly-proxy` instance to talk to in Frankfurt. 

`fly-proxy` is a Rust program built on Tokio and Hyper. It does a lot of stuff:
* Automatically handling LetsEncrypt ALPN certificate issuance for apps and transparently terminating TLS, so apps come up the first time with a solid TLS configuration.
* Routing HTTP/1.1 and HTTP2 traffic from our edge to customer VMs, with per-customer concurrency isolation.
* Coalescing HTTP/1.1 requests received on our edge into multiplexed HTTP2 sessions to our worker servers.
* Generating fine-grained Prometheus metrics for customer applications.
* Routing WebSockets connections to VMs transparently.
* Forwarding raw TCP connections for non-web applications.

What we’d like you to do for this coding challenge is to implement your own version of this proxy, so we can see how you’d do it if you were in our shoes.

HAHA WE ARE FUNNY.

What we want you to write is just the last bullet point from that feature list: a configurable raw TCP proxy.

## Part 1 - Configurable TCP proxy
First up, you’re going to build a raw TCP proxy. Just like the real `fly-proxy`, yours will be configured with multiple apps, each with potentially many backend targets.

We’ve “helpfully” included in this repo a `config.json` file to illustrate what needs to be supported. You need to support this dumb config file. Sorry.

### Criteria
* It should work.
* Don’t spend time on tests for this project.
* Don’t spend time making this perfect. Rough edges are fine if it helps you move quickly. It’s okay to skip the last 20% to make it production ready, but you should know what that 20% is and explain it in the notes.
* It listens on each port listed in the config file. Connections to any of those ports routes to one of the correct app’s targets.
* If an app has multiple targets, you should have a sensible way of balancing between targets.
* If the target you’ve chosen is unavailable for whatever reason, the connection should still work if there are multiple targets available.
Along with your code, include a NOTES.md that goes over:
* A short summary of what you built, how it works, and how you landed on this design
* What might break under a production load? What needs to happen before your proxy is production ready?
* If this were deployed to production at Fly.io, is there anything you could do with your proxy that would make our customers happy?
* If you were starting over, is there anything you’d do differently?
* How would you make a global, clustered version of your proxy?

*Important*: you can implement this proxy in Go or in Rust. We don’t care which you choose. It has to be one of those languages. Do not try to impress us by using both simultaneously. 

*Important*: don’t skimp on the notes. We read the notes before we read the code. Your notes are important. 

## Part 2 - Proxy Testing Program
Now, we want you to build some tooling to test that the proxy is working. 

You don’t need to build a custom backend to test against. You can use our test echo server for app backends:  [https://tcp-echo.fly.dev](https://tcp-echo.fly.dev/). Or you can use anything else you come up with.

You do need to write customer request/traffic generation. You can’t just shell out to netcat. 

Try to be smart about how you’re testing, what you’re looking for, and how you report results. But don’t overthink it. If you come up with something that would be worth publishing on your Github page because the wider would would find it useful, you have done way too much. 

*Important*: you picked Go or Rust for the proxy. Guess what? You need to use the other language for this. If you write a Go proxy, you need to write a Rust proxy tester. If you wrote a Rust proxy, you need to write a Go proxy tester. 

Take a deep breath. The proxy testing tool should be much smaller and simpler than the proxy! If it doesn’t look that way to you, you’ve probably overthought it. This should be a couple steps past “hello world”, for network programming. 

You can ask us for questions and advice! We want to see you in your best light. We’re not timing you, and you can only pick up points with us for asking questions; you can’t lose any.

### Criteria
* Your tool has to actually demonstrate that the proxy is working.
* It’s okay to deliver complicated features as written notes rather than code, but if you’re able to bang them out, go for it.
* Don’t spend time making this perfect. Rough edges are fine if it helps you move quickly.
* Unlike the proxy, we don’t care how you handle concurrency with this tool.
* Don’t spend time on tests for this project.

# Submitting your work
We’ll invite you to a private GitHub repo based on this template. Do all of your work in the main branch. We only care about the end result. Don’t bother with PRs, branches, or spend time on tidy commits — we have software to help us review. Just don’t force push over the initial commit or we can’t generate a diff of only your work. When you’re ready, let us know and we’ll schedule it for review. We review submissions once a week. You’ll hear back from us no matter what by the end of the /following/ week, possibly sooner if you submit early in the week.
Let us know what email address you registered with Fly and we’ll give you some credits so you can play around or launch a dev environment.

