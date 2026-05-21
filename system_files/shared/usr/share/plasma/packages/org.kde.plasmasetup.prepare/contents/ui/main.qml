// SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>
// SPDX-FileCopyrightText: 2025 Kristen McWilliam <kristen@kde.org>
// SPDX-FileCopyrightText: 2026 Macrosofty
//
// SPDX-License-Identifier: GPL-2.0-or-later
//
// Macrosofty overlay of plasma-setup's "prepare" (first) screen. Adds a
// short branded greeting above the upstream Dark Theme toggle; structure
// otherwise mirrors upstream so a plasma-setup bump is easy to re-sync.
// (Upstream also carries a commented-out display-scaling card, omitted here.)
// Strings stay wrapped in i18nc but become English-source — non-English
// users fall back to this English copy on this screen only.

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard
import org.kde.plasmasetup.prepareutil as Prepare
import org.kde.plasmasetup.components as PlasmaSetupComponents
import org.kde.plasmasetup

PlasmaSetupComponents.SetupModule {
    id: root

    cardWidth: Math.min(Kirigami.Units.gridUnit * 30, root.contentItem.width - Kirigami.Units.gridUnit * 2)

    nextEnabled: true

    contentItem: ColumnLayout {

        ColumnLayout {
            Layout.maximumWidth: root.cardWidth
            Layout.alignment: Qt.AlignCenter
            spacing: Kirigami.Units.largeSpacing

            Label {
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.gridUnit
                Layout.rightMargin: Kirigami.Units.gridUnit
                Layout.bottomMargin: Kirigami.Units.gridUnit
                Layout.alignment: Qt.AlignTop
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                text: i18nc( // qmllint disable unqualified
                    "%1 is the distro name",
                    "Welcome to <b>%1</b>. A couple of quick choices and the house is yours — you can change all of it later in System Settings.",
                    InitialStartUtil.distroName
                )
            }

            FormCard.FormCard {
                id: darkThemeCard
                maximumWidth: root.cardWidth

                Layout.alignment: Qt.AlignTop | Qt.AlignHCenter

                FormCard.FormSwitchDelegate {
                    id: darkThemeSwitch
                    text: i18n("Dark Theme")
                    checked: Prepare.PrepareUtil.usingDarkTheme
                    onCheckedChanged: {
                        if (checked !== Prepare.PrepareUtil.usingDarkTheme) {
                            Prepare.PrepareUtil.usingDarkTheme = checked;
                        }
                    }
                }
            }
        }
    }
}
