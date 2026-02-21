#!/usr/bin/env nu
print "⚠️  CLOSE HELIX FIRST!"
print ""
input "Press Enter when Helix is closed..."

print "Cleaning global jdtls cache for this project..."
# jdtls indexes projects by a hash of the project path
let cache_dirs = [
    $"($env.HOME)/.cache/jdtls",
    $"($env.HOME)/.local/share/jdtls",
    "/tmp/jdtls-*"
]
for dir in $cache_dirs {
    if ($dir | path exists) {
        print $"  Clearing ($dir)..."
        rm -rf $dir
    }
}

# rm -rf .jdtls-workspace
# rm -rf ~/.cache/jdtls/workspace/*
# rm -rf ~/.cache/jdtls/config/*

print "Cleaning Maven..."
mvn clean

print "Resolving dependencies explicitly first..."
mvn dependency:resolve -q

print "Generating sources (if any annotation processors)..."
mvn generate-sources -q

print "Installing dependencies..."
mvn install -DskipTests

if $env.LAST_EXIT_CODE == 0 {
    print "✅ Compilation successful! You can now open Helix."
} else {
    print "❌ Compilation failed. Fix errors before opening Helix."
    print "   Check errors above ^^^"
}
