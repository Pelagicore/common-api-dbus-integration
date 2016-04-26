
# Copyright (C) 2016 Pelagicore AB
#
# Permission to use, copy, modify, and/or distribute this software for
# any purpose with or without fee is hereby granted, provided that the
# above copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
# WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR
# BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES
# OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS,
# WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,
# ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS
# SOFTWARE.
#
# For further information see LICENSE.txt
#

find_package(CommonAPICodeGenCommon REQUIRED)

pkg_check_modules(COMMON_API_DBUS CommonAPI-DBus REQUIRED)

if(COMMON_API_DBUS_FOUND)
	add_definitions(${COMMON_API_DBUS_CFLAGS})
	#link_directories(${COMMON_API_DBUS_LIBRARY_DIRS})

	# Generates and installs a library containing a DBus stub and a proxy for the given interface
	macro(install_commonapi_dbus_backend LIBRARY_NAME variableName deploymentFile idlFiles interface fidl_include_paths)

		set(GENERATORS core dbus)
		
		if(NOT "${fidl_include_paths}" STREQUAL "")
                    prepare_fidl_temporary_location(${deploymentFile} "${idlFiles}" "${fidl_include_paths}")
		endif()

                get_generated_files_list("GENERATED_FILES" ${deploymentFile} "${GENERATORS}")

		add_library(${LIBRARY_NAME}_dbus SHARED
			${GENERATED_FILES}
		)

		set_target_properties(${LIBRARY_NAME}_dbus PROPERTIES VERSION 1 SOVERSION 1)

		# Once installed, the library will be called ${LIBRARY_NAME}_Backend
		set_target_properties(${LIBRARY_NAME}_dbus PROPERTIES OUTPUT_NAME ${LIBRARY_NAME}_Backend )

		message("COMMON_API_DBUS_LIBRARIES:" ${COMMON_API_DBUS_LIBRARIES})
		TARGET_LINK_LIBRARIES( ${LIBRARY_NAME}_dbus
			${COMMON_API_DBUS_LIBRARIES}
		)

		add_generated_files_command("${GENERATED_FILES}" ${deploymentFile} "${GENERATORS}")

		include_directories(${CMAKE_CURRENT_BINARY_DIR}/${COMMONAPI_GENERATED_FILES_LOCATION})

		get_library_name(BASE___ ${interface})
		install( TARGETS ${BASE___}_dbus DESTINATION lib)
		install( DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${COMMONAPI_GENERATED_FILES_LOCATION}/ DESTINATION ${SERVICE_HEADERS_INSTALLATION_DESTINATION})

	    install_franca_idl(${interface} ${deploymentFile} ${deploymentFile} "${idlFiles}")

    	add_commonapi_pkgconfig(${interface})

	endmacro()

	# Generates and installs a library containing a DBus CommonAPI stub and a proxy for the given interface
#	macro(add_commonapi_dbus_service variableName deploymentFile idlFile interface)
#		get_library_name(BASE___ ${interface})
#		set(${variableName}_LIBRARIES ${${variableName}_LIBRARIES} ${BASE___}_dbus)
#		install_commonapi_dbus_backend(${deploymentFile} ${idlFile} ${interface})
#		install_franca_idl(${interface} ${deploymentFile} ${deploymentFile} ${idlFile})
#	endmacro()
	
	
macro(add_commonapi_dbus_service variableName deploymentFile idlFile interface)

	get_library_name(BASE___ ${interface})
	set(BACKEND dbus)
	set(${variableName}_LIBRARIES -Wl,--no-as-needed ${${variableName}_LIBRARIES} ${BASE___}_${BACKEND} -Wl,--as-needed)
	install_commonapi_dbus_backend(${BASE___} ${variableName} ${deploymentFile} ${idlFile} ${interface})

endmacro()
	
endif()

