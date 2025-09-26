const {PGlite} = require('@electric-sql/pglite');
const {PGLiteSocketServer} = require('@electric-sql/pglite-socket');
const {z} = require('zod');

const AppConfig = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('production'),
  DEBUG: z.int().min(0).max(5).default(
    process.env.NODE_ENV === 'production' ? 0 : 5
  ),
});

const appConfig = AppConfig.parse(process.env);

const main = async () => {

  // Create a PGlite instance
  const db = await PGlite.create(
    "data",
    {
      debug: appConfig.DEBUG satisfies Parameters<typeof PGlite.create>[1]['debug'],
    }
  )

  // Create and start a socket server
  const server = new PGLiteSocketServer({
    db,
    port: 5432,
    host: '127.0.0.1',
    debug: appConfig.NODE_ENV === 'production',
  })

  await server.start()

  process.on('SIGINT', async () => {
    await server.stop()
    await db.close()
    console.log('Server stopped and database closed')
    process.exit(0)
  })
}

main()
  .then(() => {
    console.log('Server started on 127.0.0.1:5432')
  })
  .catch(console.error)

module.exports = main;
