# cl-module-agent

## The problem

Developing a `cl_module` normally means installing the Istari Agent on a real
machine, registering it against the platform, and redeploying/reinstalling
every time you want to test a change. That's slow, and it's easy to end up
with a machine full of half-configured agents just for iterating on module
code.

## What this is

A containerized Istari Agent for rapid development and testing of custom
`cl_module`s. It spins up an Ubuntu-based agent with your `cl_modules/`
directory mounted straight from the host, so you can edit a module on disk
and have the agent pick it up on its next restart — no reinstalling, no
re-registering, no redeploying a new agent.

The agent's identity (its registration, private key, agent ID) is stored in
Docker-managed volumes, not the image, so rebuilding the container never
creates a "new" agent on the platform.

## Use cases

- Iterating on a `cl_module`'s logic and re-running real jobs against it
  without touching agent install/registration each time.
- Reproducing a module bug in an isolated, disposable environment instead of
  a shared/production agent.

## How it works

- `Dockerfile` — stock `ubuntu:24.04` with the `istari-agent` package and the
  `stari` CLI installed.
- `entrypoint.sh` — on container start, configures the CLI and agent from
  your `.env` credentials (idempotent — skips re-init if already configured),
  patches the config for headless mode (the agent's system-tray code crashes
  without a display otherwise), and starts the agent.
- `cl_modules/` — bind-mounted onto the agent's `istari_modules` directory.
  Whatever's on disk here is exactly what the agent sees; nothing is copied
  or installed.
- Two named volumes persist agent identity/config across rebuilds and
  restarts.

**Note:** the agent scans `istari_modules` once at startup — it does not
hot-reload. Adding or editing a module requires a `docker compose restart`,
but never a rebuild or re-registration.

## Usage

1. **Configure credentials**

   ```
   cp .env.example .env
   ```

   Fill in `REGISTRY_URL`, `API_KEY` (CLI/publishing token), and `AGENT_PAT`
   (this agent's registration token).

2. **Add your module**

   Create a directory under `cl_modules/` named after your module, containing
   at minimum:

   ```
   cl_modules/<your-module>/
     cl_module            # the module's executable entrypoint
     module_config.json   # maps function names to executables/args/env
     module_manifest.json # function schemas the platform validates against
   ```

   Plus any scripts/resources the module needs at runtime.

3. **Start the agent**

   ```
   docker compose up -d --build
   ```

4. **Verify it registered**

   ```
   docker compose logs -f
   ```

   Look for `Agent initialized` and `Registered agent as <id>`.

5. **Iterate**

   Edit files under `cl_modules/` on the host, then:

   ```
   docker compose restart
   ```

   The agent comes back up as the same registered identity with the updated
   module available — no rebuild needed unless you changed the Dockerfile
   itself (e.g. bumping `AGENT_VERSION`).

## Future Work
  Will need a way to auto-register new functions with the Registry Service. The Agent currently works only with pre-registered modules that the Registry Service has already associated with this agent

## Future Vision
  Exploring way to quickly scale up identical agents on a single node to increase parallelization in Job execution. While developing a custom app making repeated module calls, it appears that module wait time could be dramatically reduced by horizontally scaling Agents able to execute the Job. Jobs are only processed by compatible Agents, meaning Agents that have OS, installed modules, and versions compatible with the Job. For Jobs not requiring external licenses, multiple Agents could theoretically be spun up to process a backlog of Jobs in parallel. 
