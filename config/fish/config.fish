# if status is-interactive
#     # Commands to run in interactive sessions can go here
# end

starship init fish | source

if command -v nvm >/dev/null
  nvm use default > /dev/null
end
# # load default nvm version (courtesy of ChatGPT)
# function use_nvmrc
#     set nvmrc_path $PWD/.nvmrc
#     if test -e $nvmrc_path
#         set nvmrc_contents (cat $nvmrc_path)
#         if test -n $nvmrc_contents
#             nvm use $nvmrc_contents > /dev/null
#         end
#     else
#         nvm use default > /dev/null
#     end
# end
#
# # Call use_nvmrc when changing directories
# function cd
#     builtin cd $argv
#     use_nvmrc
# end
#
# # Call use_nvmrc when starting fish shell
# use_nvmrc
