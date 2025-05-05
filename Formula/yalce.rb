class Yalce < Formula
  desc "Yalce sound application" 
  homepage "https://github.com/crawdaddie/yalce"
  url "https://github.com/crawdaddie/yalce.git", branch: "main"
  version "0.1.0"
  license "MIT"
  
  depends_on "sdl2"
  depends_on "sdl2_ttf" 
  depends_on "sdl2_gfx"
  depends_on "readline"
  depends_on "llvm@16"
  depends_on "libsoundio"
  depends_on "libsndfile"
  depends_on "fftw"
  
  def install
    (prefix/".env").write <<~EOS
      export BREW_PREFIX=$(brew --prefix)
      export CPATH=$BREW_PREFIX/include
      export LIBRARY_PATH=$BREW_PREFIX/lib
      export LLVM_PATH=$BREW_PREFIX/opt/llvm@16
      export SDL2_PATH=$BREW_PREFIX/opt/sdl2
      export SDL2_TTF_PATH=$BREW_PREFIX/opt/sdl2_ttf
      export SDL2_GFX_PATH=$BREW_PREFIX/opt/sdl2_gfx
      export READLINE_PREFIX=$BREW_PREFIX/opt/readline
      export LIBSOUNDIO_PATH=$BREW_PREFIX/opt/libsoundio
      export LIBSNDFILE_PATH=$BREW_PREFIX/opt/libsndfile
      export LIBFFTW3_PATH=$BREW_PREFIX/opt/fftw
    EOS

    system "make"
    # Install the binary from the build directory
    bin.install "build/ylc"
    lib.install "build/engine/libyalce_synth.so"
    lib.install "build/gui/libgui.so"
    # Update the library paths in the binary
    system "install_name_tool", "-change", 
           "@rpath/libyalce_synth.so", 
           "#{opt_lib}/libyalce_synth.so", 
           "#{bin}/ylc"
           
    system "install_name_tool", "-change", 
           "@rpath/libgui.so", 
           "#{opt_lib}/libgui.so", 
           "#{bin}/ylc"

    # Create share directory for all YALCE files
    share_path = share
    share_path.mkpath
    
    # Install engine binding files
    engine_bindings_path = share_path/"engine/bindings"
    engine_bindings_path.mkpath
    engine_bindings_path.install "engine/bindings/MIDI.ylc"
    engine_bindings_path.install "engine/bindings/Sched.ylc"
    engine_bindings_path.install "engine/bindings/Synth.ylc"
    
    # Install GUI binding files
    gui_bindings_path = share_path/"gui/bindings/gui"
    gui_bindings_path.mkpath
    gui_bindings_path.install "gui/bindings/Gui.ylc"
    
    # Install folders
    share_path.install "dev"
    share_path.install "lib"
    share_path.install "synths"
      
  end
  def caveats
    share_path = "#{opt_share}/ylc"
    <<~EOS
      YLC executable has been installed to #{bin}/ylc
      You may want to symlink that to somewhere on your path or add #{bin} itself to your path
      
      YLC modules and bindings have been installed to #{share_path}
      You may specify that as YLC's base directory for modules by adding this env var:
      
      export YLC_BASE_DIR="#{share_path}"
      
      To add this to your .zshrc file, run:
      echo 'export YLC_BASE_DIR="#{share_path}"' >> ~/.zshrc
      
      Then restart your terminal or run:
      source ~/.zshrc
    EOS
  end
  
  test do
    system "#{bin}/ylc", "--version"
  end
end
