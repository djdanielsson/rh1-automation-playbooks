# Playbook Catalog

**Complete catalog of all playbooks in the automation-playbooks repository.**

## Overview

This document lists all available playbooks, their purposes, required variables, and usage examples.

---

## deploy-webapp.yml

**Purpose**: Deploy web applications using the webserver role from custom collection.

### Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `app_name` | ✅ | - | Name of the application |
| `app_source` | ✅ | - | Source path for application files |
| `app_port` | ❌ | 8080 | Port for the application |
| `app_config_path` | ❌ | `/etc/httpd/conf.d` | Configuration directory |

### Example Usage

```yaml
# In AAP Job Template or CLI
ansible-playbook playbooks/deploy-webapp.yml \
  -e app_name=mywebapp \
  -e app_source=/project/files/ \
  -e app_port=8080
```

### Dependencies

- **Role**: `myorg.custom_collection.webserver_deploy`
- **Packages**: httpd, application dependencies
- **Ports**: Specified app_port must be available

---

## backup-database.yml

**Purpose**: Perform encrypted database backups with optional cloud storage.

### Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `db_host` | ✅ | - | Database server hostname |
| `db_name` | ✅ | - | Database name to backup |
| `db_user` | ✅ | - | Database user with backup privileges |
| `backup_dir` | ❌ | `/var/backups` | Local backup directory |
| `encryption_key` | ✅ | - | Key for encrypting backups |
| `s3_bucket` | ❌ | - | S3 bucket for cloud storage |
| `retention_days` | ❌ | 30 | Days to retain backups |

### Example Usage

```yaml
# Basic local backup
ansible-playbook playbooks/backup-database.yml \
  -e db_host=localhost \
  -e db_name=myapp \
  -e db_user=backup_user \
  -e encryption_key=my_secret_key

# With S3 upload
ansible-playbook playbooks/backup-database.yml \
  -e db_host=prod-db.example.com \
  -e db_name=production \
  -e db_user=backup_user \
  -e encryption_key=my_secret_key \
  -e s3_bucket=my-backups-bucket
```

### Dependencies

- **Role**: `myorg.custom_collection.database_backup`
- **Packages**: postgresql-client, openssl
- **Storage**: Sufficient disk space for backups
- **Credentials**: Database access, S3 credentials (if uploading)

---

## smoke-test.yml

**Purpose**: Basic platform smoke tests to validate system health.

### Variables

None required - runs basic connectivity and resource checks.

### Example Usage

```yaml
# Run smoke tests
ansible-playbook playbooks/smoke-test.yml

# Run on specific hosts
ansible-playbook playbooks/smoke-test.yml -l webservers
```

### Tests Performed

- ✅ Network connectivity (ping)
- ✅ Package manager functionality
- ✅ HTTP connectivity to external services
- ✅ Disk space validation
- ✅ Basic system health checks

### Dependencies

- **Network**: Internet access for HTTP tests
- **Disk**: Minimum 1GB free space
- **Package Manager**: Working package installation

---

## Adding New Playbooks

### Naming Convention

Use the pattern: `<action>-<component>.yml`

Examples:
- `deploy-application.yml`
- `backup-database.yml`
- `configure-network.yml`
- `monitor-services.yml`

### Required Structure

All playbooks must include:

1. **Variable validation** in pre_tasks
2. **Role-based execution** (no inline tasks)
3. **Error handling** with blocks/rescue
4. **Post-validation** in post_tasks
5. **Comprehensive documentation**

### Template

```yaml
---
# playbook-name.yml
# Brief description of what this playbook does

- name: Playbook Title
  hosts: target_hosts
  gather_facts: true

  pre_tasks:
    - name: Validate required variables
      ansible.builtin.assert:
        that:
          - required_var is defined
        fail_msg: "Required variable required_var must be defined"

  roles:
    - role: myorg.custom_collection.role_name
      vars:
        role_var: "{{ playbook_var }}"

  post_tasks:
    - name: Validate results
      ansible.builtin.assert:
        that: success_condition
        fail_msg: "Playbook validation failed"
```

### Documentation Requirements

Update this file when adding new playbooks with:

- Purpose and scope
- Required and optional variables
- Usage examples
- Dependencies and prerequisites
- Success/failure conditions

---

## Maintenance

### Regular Tasks

- **Update catalog**: Keep this document current with playbook changes
- **Dependency checks**: Monitor role changes in collections
- **Variable validation**: Ensure all required variables are documented
- **Testing**: Validate examples work with current versions

### Version Compatibility

Playbooks are versioned with the repository. When updating:

1. Test with current collection versions
2. Update variable requirements if changed
3. Update examples to match new interfaces
4. Document breaking changes
