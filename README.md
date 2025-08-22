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
    chmod +x ktbuild
    ```
4. Now you can run the script using the following command:
    ```bash
    ./ktbuild
    ```

## Recommendations
You can easily run this script by simply just typing `ktbuild` (without the full path to it) from anywhere in your terminal, by copying the script to a directory in your `$PATH`, such as `/usr/local/bin`.

```bash
sudo cp ktbuild /usr/local/bin
```

Now you can try the `ktbuild` command anywhere on your terminal and check the result.
