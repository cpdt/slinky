# Slinky

> **Super Link, Yo** - Run native Linux commands from your Windows shell!

![Using Slinky with Nano](http://i.imgur.com/RLFtEEb.gif)

Slinky allows you to run Linux commands in the Windows shell through the power of Ubuntu for Windows. Instead of having to open up `bash` whenever you need to bash out some scripts, Slinky lets you run those commands straight in your Windows command prompt.

> **Note:** Ubuntu for Windows is currently a part of the Windows Insider _fast_ ring, and so is unstable and breaks from time to time. Use with caution!

## Install

Open up Bash (hit Start, type `bash` and press [Enter]) and enter the following command (making sure that `curl` is installed first -- you can install it with `sudo apt-get install curl`).

```bash
curl -o- https://raw.githubusercontent.com/cpdt/slinky/master/install.sh | /bin/bash
```

Slinky will automagically download and install, however to be able to run Slink-ed commands from Windows, you must add the following path to your Windows PATH variable (to edit the PATH variable, hit start, type `environment variables` and press [Enter], click `Environment variables...`, select `Path` in the top list, and hit `Edit`). Add the following path:

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

## License

Slinky is licensed under the MIT license, included in the `LICENSE` file.
