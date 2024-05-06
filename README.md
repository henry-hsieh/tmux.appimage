# tmux.appimage

This project automates the process of building an AppImage for [tmux](https://github.com/tmux/tmux), a terminal multiplexer for Unix-like operating systems. The resulting AppImage allows users to run tmux on various Linux distributions without needing to install it, providing a portable and consistent experience across different systems.

## How to Use

### Downloading the AppImage

You can download the latest release of the tmux AppImage from the [Releases](https://github.com/henry-hsieh/tmux.appimage/releases) page. Simply download the `.AppImage` file and make it executable using the following command:

```bash
chmod +x Tmux-x86_64.AppImage
```

### Running tmux

Once the AppImage is downloaded and made executable, you can run it from the terminal:

```bash
./Tmux-x86_64.AppImage
```

Or put to your system binary path:

```bash
sudo cp ./Tmux-x86_64.AppImage /usr/bin/tmux
```

### Building from Source

If you want to build the tmux AppImage from source yourself, you can clone this repository and run the provided build script. Ensure you have the necessary dependencies installed on your system:

- GNU Make
- Docker

```bash
git clone https://github.com/henry-hsieh/tmux.appimage.git
cd tmux.appimage
make -j
make install prefix=/path/to/install
```

This will generate the tmux AppImage in the `build` directory.

## Contributing

Contributions to this project are welcome! If you encounter any issues or have suggestions for improvement, please feel free to open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE), which means you are free to use, modify, and distribute the code as you see fit.
