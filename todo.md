## Version 0:

- deploy app to GKE
- deploy pachyderm cluster to GKE
- deploy tensor flow pipeline to GKE
- update app to display result of pipeline

## Version 1: Support multiple sentences

Update App:

- Update routes to handle
    - / which redirects to /random
    - /random which 

Update Code:

1) Output `sentences.json` which is a list of valid sentences, indexed by hash, e.g:

```
[
    "234345347e09",
    "a464efbcd987",
    ...
]
```

2) Save each new quote in a separate file under `sentences/` named as the hash of its contents, e.g. `sentences/a464efbcd987`

3) Have a mechanism to 'save' the results of the branch into a different branch?

E.g. I'd like to run a job and have it merge all the new sentences into a `production` branch. 

Not sure if I want this to be automatic or not. Or, if I'm running one off jobs off a single parent commit if it really matters. Have to think on this.

## Version 2: Better model

Train the model w more data, and better normalization, to get better results.


## Version 3: Polish the app

- buy a DNS name, hook it in
- add some css / styles
- maybe basic hit rate tracking
- maybe some mechanisms to scale it?

