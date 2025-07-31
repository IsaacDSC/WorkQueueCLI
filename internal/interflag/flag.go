package interflag

import "os"

func ParseGlobalFlag(flagName, defaultValue string) string {
	for i, arg := range os.Args {
		if arg == flagName && i+1 < len(os.Args) {
			return os.Args[i+1]
		}
	}
	return defaultValue
}

func FindSubcommandIndex() int {
	skipNext := false
	for i := 2; i < len(os.Args); i++ {
		if skipNext {
			skipNext = false
			continue
		}

		arg := os.Args[i]
		if arg == "--host" {
			skipNext = true
			continue
		}

		if !IsFlag(arg) {
			return i
		}
	}
	return -1
}

func IsFlag(arg string) bool {
	return len(arg) > 0 && arg[0] == '-'
}

func ParseFlag(flagName string) string {
	for i, arg := range os.Args {
		if arg == flagName && i+1 < len(os.Args) {
			return os.Args[i+1]
		}
	}
	return ""
}
