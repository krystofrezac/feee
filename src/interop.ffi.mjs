import fs from 'fs'

export const readDir = (path) => {
	const dir = fs.readdirSync(path, { withFileTypes: true })
	return dir.map(item => [
		item.name,
		item.isFile()
	])
}

export const getArgv = () => {
	return process.argv.slice(2)
}
