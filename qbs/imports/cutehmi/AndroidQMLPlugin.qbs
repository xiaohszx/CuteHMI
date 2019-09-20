import qbs
import qbs.FileInfo
import qbs.File

import "CommonProduct.qbs" as CommonProduct

CommonProduct {
	name:  "android_" + extensionName

	condition: qbs.targetOS.contains("android")

	type: ["dynamiclibrary", "android.nativelibrary"]

	targetName: extensionName

	cutehmiType: "androidQMLPlugin"

	baseName: isNaN(extensionName.substr(extensionName.lastIndexOf(".", extensionName.length - 1) + 1)) ? extensionName : extensionName.substring(0, extensionName.lastIndexOf(".", extensionName.length - 1))

	files: {
		var namespaceRelativePath = baseName.toLowerCase().replace(/\./g, '/')

		var pathArray = [
			sourceDirectory,
			"src",
			namespaceRelativePath,
			"internal"
		]

		var internalDirPath = pathArray.join('/')

		var headerPath = internalDirPath + "/QMLPlugin.hpp"
		var sourcePath = internalDirPath + "/QMLPlugin.cpp"

		return [headerPath, sourcePath]
	}

	property string extensionName

	property string extensionRelativePath: FileInfo.relativePath(cutehmi.dirs.extensionsSourceDir, sourceDirectory)

	Group {
		name: "Android QML plugin"
		fileTagsFilter: "dynamiclibrary"
		qbs.install: true
		qbs.installDir: cutehmi.dirs.extensionInstallDirname + "/" + extensionRelativePath
	}

	Depends { name: extensionName }

	Depends { name: "cutehmi.dirs" }

	Depends { name: "Qt.qml" }
}

//(c)MP: Copyright © 2019, Michal Policht <michpolicht@gmail.com>. All rights reserved.
//(c)MP: This file is a part of CuteHMI.
//(c)MP: CuteHMI is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//(c)MP: CuteHMI is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more details.
//(c)MP: You should have received a copy of the GNU Lesser General Public License along with CuteHMI.  If not, see <https://www.gnu.org/licenses/>.