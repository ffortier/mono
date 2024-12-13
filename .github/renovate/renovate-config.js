module.exports = {
    allowPostUpgradeCommandTemplating: true,
    allowedPostUpgradeCommands: [
        "^\\.\\/\.github\\/renovate\\/post-upgrade\\.sh"
    ],
    platform: 'github',
    repositories: ['ffortier/mono'],
}