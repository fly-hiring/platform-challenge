Product Take-Home

**Part 1: The Interrogation**

This is an exercise about product thinking and feature design. You&#39;re not going to write any code, and it shouldn&#39;t take too much of your time.

Here&#39;s the deal: our customers are asking us for a &quot;database fork&quot; feature. They want to take an existing, running Postgres database, and get a new database running with identical data. That&#39;s it, that&#39;s the ask.

Your job here is to figure out what we should build.

There are bunch of different ways to clone a Postgres database. But be careful: we don&#39;t want to build Postgres features. We don&#39;t want to build things that are specific to any database. What we want to do is build infrastructure that works for ANY database, so that ANYBODY can build a hosted database product on Fly.io: hosted Postgres, or hosted MySQL, or hosted Mongo, or SQLite, or whatever.

You&#39;ll have have 2 deliverables:

- Define what this feature is, and come up with several use cases that show why it&#39;s valuable to customers.  
- Figure out a good UX for exposing the feature to our customers.

But: You&#39;re not ready to do either of those things yet. So, before you get started, we want you to send us questions. Ask us for any information that will help you figure out what to build. We&#39;ll answer anything we can. You can ask us about:

- What typical customers look like
- How our platform works
- Particular, specific constraints you&#39;re concerned our customers might have
- Ideas you want to bounce off us
- Anything else you come up with to ask

Remember, we don&#39;t care how much you know up front. Knowing too much might even put you at a disadvantage! We DO care about how well you work with incomplete information and how effective you are at finding answers. Ask lots of questions, and make them smart questions.

For this challenge, this is your one shot to get your questions answered, so try to come up with everything you&#39;ll need. Just a simple emailed list would be great (don&#39;t make us click a link or a PDF or anything). We&#39;ll answer your questions in another email.

**Part 2: The Feature Spec**

Ok, here goes! As a reminder, this is what we&#39;re looking for:

Customers are asking us for a &quot;database fork&quot; feature. They want to take an existing, running Postgres database, and get a new database running with identical data.

You have 2 deliverables:

- Define what this feature is, and come up with several use cases that show why it&#39;s valuable to customers.
- Figure out a good UX for exposing the feature to our customers.

Please reply with a simple email (you don&#39;t need to make an official-looking document for this, it&#39;ll just slow us down). It should include, in this order:

1. A description of the feature you came up with. Don&#39;t spend much time on how it works, just what the customer sees.
1. A list of use cases for the feature. When and how does this feature get used by customers? Be specific.
1. Finally, a description of the UX for the feature. We&#39;re a CLI-first company. Get familiar with `flyctl`. Then: what does a user &quot;do&quot; to make this feature work, and what do they see when they do it?
