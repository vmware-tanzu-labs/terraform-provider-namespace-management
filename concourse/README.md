# Concourse automation

Due to the nature of complex multi-host testing it is not possible
to use standard GitHub CI automation to test everything within
this project's repositories.

It is insufficient to test just the provider code or to
use the vcsim software to validate this terraform module.
This is because vcsim's code is created to precisely match
the vCenter API Go wrapper in the same repository - so it is
much more likely any bug in the Go API wrapper has been duplicated
in the vcsim software that was created for it.

There is also the problem of regressions. As new software comes
out we need to run tests against this new infrastructure.
GitHub CI only tests the code at the point when code is created
or a Pull Request submitted. So we need another way to monitor
and detect upstream software changes - as they happen - and test
various supported combinations of VMware software against these
Terraform modules. We also need to do this against multiple
platforms many of which are on different networks.

This is where Concourse, the generic thing do-er, comes in.
Concourse is a Free and Open Source Software (FOSS) project
that allows for a declarative event-driven approach to testing
software as new builds are released. Concourse proactively
monitors a set of dependencies and if they change will kick
off a build.

This folder holds the tests and supported platform combinations
and configurations for both the development branch (/concourse/develop)
and main branch (/concourse/main) code repositories.

When changes occur, the Concourse runtime on multiple servers will
initiate, perform a FRESH infra rollout and automate any additional
practical checks and tests. If any issues are found they will be 
summarised and added to a GitHub Issue automatically.

## Contents

* main folder - tests that run against the current release and prior releases
* develop folder - tests that run against the current develop branch
* FOLDER/pipeline-*.yaml - A single pipeline in Concourse
* FOLDER/settings-*.yaml - Settings that automated CI may update
* combinations folder - One file per supported product combination

### Common question: Shouldn't the develop tests live in the develop branch?

No. The develop branch is for 'changes undergoing testing' Thus the develop
branch of the main folder is 'changes we're trying out to tests we want
to apply to current and previous releases' and the develop branch of the
develop folder is 'changes we're trying out to the tests of the things
we're adding/building in the develop branch'. So whilst the naming
is similar, the reasoning for using BOTH folder names and branches is sound.

## How this works

We maintain a set of settings in the settings-combinations.yaml file. This
uses the [experimental instance groups feature](https://concourse-ci.org/instanced-pipelines.html)
of Concourse to instantiate a pipeline per target test environment.
This means a single pipeline definition is instantiated for each version combination
and settings, enabling us to test upcoming versions we've not specifically
coded for upon release.

## TODO items

In order of decreasing value to this project and its users:-

Immediate / Proof of Concept:-

* As a new develop merge occurs, run the real tests against a new rollout on Adam's Homelab on 7.0.3 with vDS and Avi

Before v1.0 release:-

* Support for NSX-T deployments
* Support for NSX-T with Avi deployments
* Most secure by default (See ../security/README.md for details) settings and tests (poor man's pen testing)
* Automation for current supported (Beyond Sep 2022) version combinations of vSphere with Tanzu (See combinations/ for details)

Futures:-

* Help other teams deliver the same for TKGm (Multicloud) and TKGI (integrated) on different cloud platforms
