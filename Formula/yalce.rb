class Yalce < Formula
  desc "Your audio/sound application" # Replace with a proper description
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
      
    # Install environment file
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
  end
  
  test do
    # If your app supports running with a --version flag
    system "#{bin}/ylc", "--version"
    
    # Alternative test if --version isn't supported:
    # assert_predicate bin/"ylc", :exist?
  end
end
