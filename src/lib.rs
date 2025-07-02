//! # Rust Actions Toolkit
//!
//! This is a GitHub Actions toolkit for Rust projects, not a Rust library.
//! The actual functionality is provided through GitHub Actions and workflows.
//!
//! This lib.rs file exists only for release-plz compatibility and is not
//! intended to be used as a Rust dependency.

#![doc = include_str!("../README.md")]

/// This crate is a GitHub Actions toolkit, not a Rust library.
/// 
/// Please refer to the GitHub repository for usage instructions:
/// https://github.com/loonghao/rust-actions-toolkit
pub fn github_actions_toolkit() {
    println!("This is a GitHub Actions toolkit, not a Rust library.");
    println!("Please visit: https://github.com/loonghao/rust-actions-toolkit");
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_github_actions_toolkit() {
        github_actions_toolkit();
    }
}
