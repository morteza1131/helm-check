# Helm Check in CI/CD

## Overview

You can check if previous deployment is succed or not, sometimes in ci/cd deployment in some condition like cancelling deploy stage in middle of deployment, Helm deploy state become one of pending-install, pending-upgrade or pending-rollback and we could not deploy agian untill we fix the issue by manually executing helm rollback command.

You can use this script in your CI/CD env and automatically fix the issue.

## Usage

```bash
./helm-check.sh NAMESPACE RELEASE_NAME
```
