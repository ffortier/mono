module.exports = {
    allowPostUpgradeCommandTemplating: true,
    allowedPostUpgradeCommands: [
        "^\\.\\/\.github\\/renovate\\/post-upgrade\\.sh"
    ],
    platform: 'github',
    gitAuthor: 'Renovate Bot <bot@renovateapp.com>',
    repositories: ['ffortier/mono'],
    username: 'renovate',
}