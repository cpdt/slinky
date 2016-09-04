# Slinky

> **Super Link, Yo** - Run native Linux commands from your Windows shell!

![Using Slinky with Nano](http://i.imgur.com/RLFtEEb.gif)

Slinky allows you to run Linux commands in the Windows shell through the power of Ubuntu for Windows. Instead of having to open up `bash` whenever you need to bash out some scripts, Slinky lets you run those commands straight in your Windows command prompt.


**You will need Windows build 14316 or later in order to use Slinky** (this is the first build that includes a usable version of Ubuntu for Windows). This either means you must be running the Aniversary update (or later), or a build after 14316 in the fast ring.

## Install

Open up Bash (hit Start, type `bash` and press [Enter]) and enter the following command (making sure that `curl` is installed first -- you can install it with `sudo apt-get install curl`).

```bash
curl -o- https://raw.githubusercontent.com/cpdt/slinky/1.2/install.sh | /bin/bash
```

Slinky will automagically download and install, however to be able to run Slink-ed commands from Windows, you must add the following path to your Windows PATH variable (to edit the PATH variable, hit start, type `environment variables` and press [Enter], click `Environment variables...`, select `Path` in the top list, and hit `Edit`).

```
C:\.slinky
```

## Usage

In your Bash or Windows shell, run the command below to link a command in the Windows prompt to a Bash command (i.e running the command in the Windows prompt will actually run the Bash command).

```bash
$ slink [command name]
```

Alternatively, you can assign a different name to the Windows command by providing two parameters:

```bash
$ slink [windows command] [linux command]
```

> **Example 1:**
> Link the `curl` command so it is runnable from Windows:
> ```bash
> C:\> slink curl
> C:\> curl ...etc...
> ```
> **Example 2:**
> Link Linux's `echo` command so it is runnable as `do-echo` from Windows:
> ```bash
> C:\> slink do-echo echo
> C:\> do-echo ...etc...
> ```

#### Delete a link

You can delete a link with the `rmslink` command.

```bash
$ rmslink [windows command]
```

> **Example 1:**
> Remove a link for the `curl` command:
> ```bash
> C:\> rmslink curl
> ```
> **Example 2:**
> Remove a link between Linux's `echo` command and the `do-echo` command on Windows:
> ```bash
> C:\> rmslink do-echo
> ```

#### List all links

You can view a list of the Windows command names of all commands with the `lsslink` command.

```bash
$ lsslink
```

#### Uninstall Slinky

Tired of being awesome and want to go back to being a regular command-prompt user? The `delslink` command is for you! This command will, as the name suggests, delete Slinky and all related files from your computer. **Slinky links will not be kept around, so if you uninstall Slinky and then re-install, you will need to re-create all of your links.**

```bash
$ delslink
```

#### Usage in Bash

The Slinky commands can be used in Bash (or another shell). By default, they are installed in `/usr/local/bin`, so will be usable as long as this is in your path.

#### Advanced Configuration

##### Installation Path

The installation path can be changed by modifying the `$install_dir` variable in `install.sh` or `install-local.sh` before they are run.

##### Other Options

Slinky provides a configuration file called `slinky.cfg` in the installation directory. This file has the following options:

 - `install_dir` - the directory to place the link batch files as a Linux path. In order to use the linked commands in the Windows prompt, the Windows version of this path must be added to the PATH environment variable. Default is `/mnt/c/.slinky`.
 - `run_file` - the Linux path to the bash script run by the link batch files. The script is called with the command line to run (i.e the command name followed by parameters). Note that this value is saved into each batch file, and so if the file is moved, the locations must be updated in each file. Default is `/usr/local/bin/slinky-run.sh`.
 - `win_bash` - the Windows path to the bash executable (`bash.exe`). The command to run will be passed as the parameters. Note that this value is saved into each batch file, and so if the file is moved, the locations must be updated in each file. Default is `C:/Windows/System32/bash.exe`.

## License

Slinky is licensed under the MIT license, included in the `LICENSE` file.
