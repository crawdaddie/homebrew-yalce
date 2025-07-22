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
    brew_prefix = HOMEBREW_PREFIX
    env_content = "export CPATH=#{brew_prefix}/include\n" +
                  "export LIBRARY_PATH=#{brew_prefix}/lib\n" +
                  "export LLVM_PATH=#{brew_prefix}/opt/llvm@16\n" +
                  "export SDL2_PATH=#{brew_prefix}/opt/sdl2\n" +
                  "export SDL2_TTF_PATH=#{brew_prefix}/opt/sdl2_ttf\n" +
                  "export SDL2_GFX_PATH=#{brew_prefix}/opt/sdl2_gfx\n" +
                  "export READLINE_PREFIX=#{brew_prefix}/opt/readline\n" +
                  "export LIBSOUNDIO_PATH=#{brew_prefix}/opt/libsoundio\n" +
                  "export LIBSNDFILE_PATH=#{brew_prefix}/opt/libsndfile\n" +
                  "export LIBFFTW3_PATH=#{brew_prefix}/opt/fftw\n"
    
    File.write(".env", env_content)

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
    <<~EOS
      YLC executable has been installed to #{bin}/ylc
      You may want to symlink that to somewhere on your path or add #{bin} itself to your path
      
      YLC modules and bindings have been installed to #{opt_share}
      You may specify that as YLC's base directory for modules by adding this env var:
      
      export YLC_BASE_DIR="#{opt_share}"
      
      To add this to your .zshrc file, run:
      echo 'export YLC_BASE_DIR="#{opt_share}"' >> ~/.zshrc
      
      Then restart your terminal or run:
      source ~/.zshrc
    EOS
  end
  
  test do
    system "#{bin}/ylc", "--version"
  end
end
