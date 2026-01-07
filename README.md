# Automation Playbooks Repository

**Centralized repository for Ansible playbooks used across the Cloud-Native Ansible Lifecycle Platform.**

## Purpose

This repository contains all Ansible playbooks that are called by AAP Job Templates. Playbooks are versioned separately from AAP configuration to allow:

- Independent lifecycle management of automation logic
- Reusable playbooks across different environments/projects
- Better testing and validation of playbook changes
- Clear separation between "what to run" (AAP config) and "how to run it" (playbooks)

## Repository Structure

```
automation-playbooks/
├── README.md                          # This file
├── devfile.yaml                       # Dev container configuration
├── playbooks/                         # Main playbooks directory
│   ├── deploy-webapp.yml             # Web application deployment
│   ├── backup-database.yml           # Database backup automation
│   ├── configure-network.yml         # Network configuration
│   └── smoke-test.yml                # Platform smoke tests
├── roles/                            # Local roles (symlinks to collections)
├── inventory/                        # Inventory templates
│   ├── templates/
│   └── dynamic/
├── scripts/                          # Helper scripts
│   ├── validate-playbooks.sh
│   └── test-playbooks.sh
├── tests/                            # Playbook tests
│   ├── integration/
│   └── unit/
└── docs/                             # Playbook documentation
    ├── PLAYBOOKS.md                  # Playbook catalog
    └── STANDARDS.md                  # Playbook standards
```

## Playbook Standards

### Naming Convention

Playbooks follow the pattern: `<action>-<component>.yml`

Examples:
- `deploy-webapp.yml`
- `backup-database.yml`
- `configure-network.yml`
- `smoke-test.yml`

### Structure Requirements

All playbooks must:

1. **Include roles from collections** (not inline tasks)
2. **Use variables abstracted to defaults**
3. **Include proper error handling**
4. **Be idempotent**
5. **Have comprehensive documentation**

### Example Playbook

```yaml
---
# deploy-webapp.yml
- name: Deploy web application
  hosts: webservers
  gather_facts: true

  roles:
    - role: myorg.custom_collection.webserver_deploy
      vars:
        app_name: "{{ app_name | default('myapp') }}"
        app_source: "{{ app_source | default('/project/files/') }}"
```

## Dependencies

Playbooks depend on:

- **Collections**: Roles called by playbooks come from `automation-collection-example`
- **Execution Environment**: Runtime dependencies provided by `automation-ee-example`
- **Inventory**: Dynamic inventory from AAP or static inventory templates

## Versioning

This repository is versioned via Git SHA in release manifests, allowing:

- Atomic promotion of playbook changes
- Rollback to previous playbook versions
- Independent testing of playbook modifications
- Audit trail of automation changes

## Testing

Playbooks are tested through:

- **Syntax validation**: `ansible-playbook --syntax-check`
- **Linting**: `ansible-lint`
- **Integration tests**: Molecule scenarios using the EE
- **Smoke tests**: Basic functionality validation

## Usage in AAP

### Job Template Configuration

```yaml
# In aap-config-as-code/group_vars/aap_dev/job_templates.yml
controller_job_templates:
  - name: "Deploy Web App (Dev)"
    job_type: run
    project: "Automation Playbooks"  # References this repo
    playbook: "playbooks/deploy-webapp.yml"
    execution_environment: "Custom EE (Dev)"
    credentials:
      - "Dev SSH Key"
```

### Project Configuration

```yaml
# In aap-config-as-code/group_vars/aap_dev/projects.yml
controller_projects:
  - name: "Automation Playbooks"
    scm_type: git
    scm_url: https://github.com/djdanielsson/rh1-automation-playbooks.git
    scm_branch: main
    credential: "GitHub Token"
```

## Development Workflow

### 1. Create New Playbook

```bash
# Create playbook file
vi playbooks/new-automation.yml

# Add required documentation
vi docs/PLAYBOOKS.md

# Test syntax
ansible-playbook --syntax-check playbooks/new-automation.yml
```

### 2. Test Playbook

```bash
# Lint playbook
ansible-lint playbooks/new-automation.yml

# Run integration tests
./scripts/test-playbooks.sh
```

### 3. Create Pull Request

```bash
git add .
git commit -m "Add new automation playbook"
git push origin feature/new-playbook
gh pr create --title "Add new playbook" --body "Adds automation for XYZ"
```

### 4. CI/CD Pipeline

PR triggers:
- Syntax validation
- Linting
- Basic smoke tests
- Collection dependency checks

### 5. Promotion

After merge, playbooks are promoted via release manifest:

```yaml
# automation-release-manifest/releases/release-26.01.06.0.yaml
components:
  playbooks:
    repository: "https://github.com/djdanielsson/rh1-automation-playbooks.git"
    commit: "abc123..."  # Git SHA locks playbook version
```

## Relationship to Other Repositories

| Repository | Relationship | Purpose |
|------------|--------------|---------|
| `automation-collection-example` | **Depends on** | Provides roles called by playbooks |
| `automation-ee-example` | **Depends on** | Provides runtime environment for playbooks |
| `aap-config-as-code` | **References** | Job templates and projects reference playbooks |
| `cluster-config` | **Independent** | Platform infrastructure |
| `automation-release-manifest` | **Versioned by** | Release manifests lock playbook SHAs |

## Best Practices

### 1. Role-Based Design

Always use roles from collections, never inline tasks:

```yaml
# ✅ Good
roles:
  - role: myorg.custom_collection.database_backup

# ❌ Bad
tasks:
  - name: Install PostgreSQL client
    package: name=postgresql-client state=present
```

### 2. Variable Abstraction

All hardcoded values must be abstracted to variables:

```yaml
# ✅ Good
- role: myorg.custom_collection.webserver_deploy
  vars:
    app_port: "{{ app_port | default(8080) }}"
    app_name: "{{ app_name }}"

# ❌ Bad
- role: myorg.custom_collection.webserver_deploy
  vars:
    app_port: 8080  # Hardcoded
    app_name: myapp # Hardcoded
```

### 3. Error Handling

Include proper error handling and validation:

```yaml
- name: Validate required variables
  assert:
    that:
      - app_name is defined
      - app_source is defined
    fail_msg: "Required variables app_name and app_source must be defined"

- name: Deploy with error handling
  block:
    - role: myorg.custom_collection.webserver_deploy
  rescue:
    - name: Log failure
      debug:
        msg: "Deployment failed: {{ ansible_failed_result }}"
  always:
    - name: Cleanup
      file:
        path: /tmp/deployment_artifacts
        state: absent
```

## Maintenance

### Regular Tasks

- **Dependency updates**: Monitor collection and EE changes
- **Security scans**: Regular vulnerability assessments
- **Performance monitoring**: Track playbook execution times
- **Documentation updates**: Keep playbook catalog current

### Breaking Changes

When making breaking changes:

1. Update dependent collections first
2. Test in dev environment
3. Update AAP job templates
4. Create new release manifest
5. Promote through environments

## Support

For questions about playbooks:

- Check `docs/PLAYBOOKS.md` for catalog
- Review `docs/STANDARDS.md` for guidelines
- Test locally with `ansible-playbook --check`
- Use the platform's testing infrastructure
