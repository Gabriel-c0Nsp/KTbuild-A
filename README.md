# KTbuild-A
`KTbuild-A` is a tool designed to assist Android
programmers on the command line. It is particularly 
useful in scenarios where the user wants to build one 
of their projects quickly without the need to open an
IDE. The "A" in KTbuild stands for [Android](https://developer.android.com/).

KTbuild-A can also be helpful for users who wish to explore the process of developing an `Android` application without relying on a dedicated IDE.

## features:
* Checks emulators
* Checks connected devices (physically)
* Verifies Android installation (via SDK)
* Builds based on the items above

## Get started:

1. Clone the repository:
    ```bash
    git clone https://github.com/Gabriel-c0Nsp/KTbuild-A.git
    ```
2. Navigate to the repository:
    ```bash
    cd KTbuild-A/
    ```
3. Make sure the script has executable permissions. If not, run the following command:
    ```bash
    chmod +x ktbuild.sh
    ```
4. Now you can run the script using the following command:
    ```bash
    ./ktbuild.sh
    ```

## Recommendations
You can easily run this script by simply just typing `ktbuild` (or whatever you want) in your terminal, by setting an alias to your `.bashrc` or `.bash_profile`. If you're not using bash, you can search how to create aliases for you're specific shell.

First, you need to identify the current directory of the repository. This can be achieved with the following command:
   ```bash
   pwd
   ```
This output is important for the following process. The output of the `pwd` command is personal and will be referred in this documentation as `{current_directory}` for generalization purposes.

Finally, you can add the following instructions to your `.bashrc` or `.zshrc` file:

   ```bash
   export PATH=$PATH:{current_directory}/KTbuild-A/
   alias ktbuild='ktbuild.sh'
   ```
Don't forget to change the path in the `export PATH=...` command as needed.

Now you can try the `ktbuild` command anywhere in your terminal and check the result.
