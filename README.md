# Slinky

> **Super Link, Yo** - Run native Linux commands from your Windows shell!

![Using Slinky with vim](http://i.imgur.com/jcrOFYF.gif)

Slinky allows you to run Linux commands in the Windows shell - instead of having to open up a Bash Windows implementation whenever you need to bash out some scripts, Slinky lets you run those commands straight from your Windows (or Powershell) command prompt.

**Slinky requires an implementation of `bash` to be installed on your computer.** If you're running the Windows 10 Aniversary update or later, you can [use the in-built Ubuntu for Windows bash](http://www.howtogeek.com/249966/how-to-install-and-use-the-linux-bash-shell-on-windows-10/). Otherwise, install an alternate tool such as [Git Bash](https://git-for-windows.github.io/)/[MSYS Bash](http://www.mingw.org/wiki/msys) or [Cygwin](https://www.cygwin.com/).

## Install

All of the scripts below download a Powershell script and execute it on your machine.

**Cmd.exe**
```
@powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/cpdt/slinky/1.3/install.ps1'))"
```

**Powershell.exe** (ensure [Get-ExecutionPolicy](https://technet.microsoft.com/library/hh847748.aspx) is at least RemoteSigned)
```
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/cpdt/slinky/1.3/install.ps1'))
```

**Powershell v3+** (ensure [Get-ExecutionPolicy](https://technet.microsoft.com/library/hh847748.aspx) is at least RemoteSigned)
```
iwr https://raw.githubusercontent.com/cpdt/slinky/1.3/install.ps1 -UseBasicParsing | iex
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

## License

Slinky is licensed under the MIT license, included in the `LICENSE` file.
