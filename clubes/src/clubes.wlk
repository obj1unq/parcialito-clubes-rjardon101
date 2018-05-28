class Club {

	var property focoDeInstitucion = "x"
	var property listaDeJugadores = #{}
	var property listaDeAfiliados = #{}
	var property estaSancionado
	var gastoMensual = 0
	var listaDeActividades = #{}
	var listaDeEquipos = #{}

	method estaSancionado(unaActividad) {
		if (self.listaDeAfiliados().size() > 500) {
			estaSancionado = true
			unaActividad.cantidadDeSanciones() + 1
		} else estaSancionado = false
	}

	method evaluacionBruta()

	method clubPrestigioso() {
		return listaDeEquipos.filter({ equipo => equipo.equipoExperimentado() }) > 0 or listaDeActividades.filter({ actividad => actividad.cantidadDeParticipantes() > 5 }) > 0
	}

}

class ClubTradicional inherits Club {

	override method evaluacionBruta() {
		return listaDeActividades.sum({ actividades => actividades.puntaje() }) - gastoMensual
	}

}

class ClubComunitario inherits Club {

	override method evaluacionBruta() {
		return listaDeActividades.sum({ actividades => actividades.puntaje() })
	}

}

class ClubProfesional inherits Club {

	override method evaluacionBruta() {
		return listaDeActividades.sum({ actividades => actividades.puntaje() }) * 2 - 5 * gastoMensual
	}

}

class Equipo inherits ActividadSocial {

	var property plantel = #{}
	var property esCampeon = true
	var esCapitan = "unJugador"

	method esCapitan(unJugador) {
		return unJugador == esCapitan
	}

	method tamanioDelPlantel() {
		return plantel.size()
	}

	method puntajeDeEquipo(unSocio, unClub) {
		if (self.esCampeon() and self.esCapitan(unSocio)) {
			puntaje = self.tamanioDelPlantel() + 10
		} else (if (self.esCampeon() or self.esCapitan(unSocio)) {
			puntaje = self.tamanioDelPlantel() + 5
		} else puntaje = self.tamanioDelPlantel() )
	}

	method puntajeDeSanciones() {
		return cantidadDeSanciones * 20
	}

	method equipoExperimentado() {
		return plantel.size() == plantel.filter({ jugador => jugador.cantidadDePartidos() > 10 }).size()
	}

}

class EquipoDeFutbol inherits Equipo {

	method cantidadDeJugadoresEstrella(unSocio, unClub) {
		return plantel.filter({ jugador => jugador.esUnJugadorEstrella(unSocio, unClub) }).size()
	}

	override method puntajeDeEquipo(unSocio, unClub) {
		if (self.esCampeon() and self.esCapitan(unSocio)) {
			puntaje = self.tamanioDelPlantel() + 10 + self.cantidadDeJugadoresEstrella(unSocio, unClub)
		} else (if (self.esCampeon() or self.esCapitan(unSocio)) {
			puntaje = self.tamanioDelPlantel() + 5 + self.cantidadDeJugadoresEstrella(unSocio, unClub)
		} else puntaje = self.tamanioDelPlantel() )
	}

}

class Jugador inherits Equipo {

	var property valorDePase = 0
	var property cantidadDePartidos = 0

	method transferencia(unClub, otroClub, unSocio, destacados, unEquipo, otroEquipo) {
		if (!self.esDestacado(unSocio, destacados)) {
			unClub.listaDeAfiliados().remove(unSocio)
			unClub.listaDeJugadores().remove(unSocio)
			unEquipo.plantel().remove(unSocio)
		}
		otroClub.listaDeAfiliados().add(unSocio)
		otroClub.listaDeJugadores().add(unSocio)
		otroEquipo.plantel().add(unSocio)
		cantidadDePartidos = 0
	}

	method esDestacado(unSocio, destacados) {
		return unSocio.listaDeDestacados(destacados).contains(unSocio)
	}

}

class ActividadSocial inherits Club {

	var estaSancionada
	var property cantidadDeSanciones = 0
	var property puntaje
	var cantidadDeParticipantes //se usa en el metodo "clubPrestigioso"

	method estaSancionado() {
		estaSancionada = true
		cantidadDeSanciones += 1
	}

	method reactivarActividad() {
		estaSancionada = false
	}

	method estaSuspendida() {
		return estaSancionada
	}

	method tieneSancion() {
		puntaje = 0
	}

}

class Socio inherits ActividadSocial {

	var property cantidadDeAnios = 0
	var property cantidadDeActividades = 0
	var property esOrganizador // buleano, se usa en el metodo "lista de organizadores"

	method esJugador(unSocio, unClub) {
		return unClub.listaDeJugadores().contains(unSocio)
	}

	method tipoDeClub(unClub) {
		return unClub.focoDeInstitucion()
	}

	method esEstrellaProfecional(unSocio) {
		return unSocio.valorDePase() > 20000000
	}

	method esEstrellaComunitaria(unSocio) {
		return self.cantidadDeActividades() > 3
	}

	method esEstrellaTradicional(unSocio) {
		return self.esEstrellaProfecional(unSocio) or self.esEstrellaComunitaria(unSocio)
	}

	// nota: se que no está del todo bien poner una misma condicion repetida en un mismo metodo
	// pero no se me ocurrió otra forma de hacerlo 
	method esUnJugadorEstrella(unSocio, unClub) {
		if (self.tipoDeClub(unClub) == "profesional") {
			return self.esEstrellaProfecional(unSocio)
		} else (if (self.tipoDeClub(unClub) == "comunitario") {
			return self.esEstrellaComunitaria(unSocio)
		} else return self.esEstrellaTradicional(unSocio) )
	}

	method esEstrella(unSocio, unClub) {
		if (self.esJugador(unSocio, unClub)) {
			return self.esUnJugadorEstrella(unSocio, unClub)
		} else return self.cantidadDeAnios() > 20
	}

	method listaDeOrganizadores() {
		return listaDeAfiliados.filter({ socio => socio.esOrganizador() })
	}

	method listaDeCapitanes() {
		return listaDeAfiliados.filter({ socio => socio.esCapitan() })
	}

	method listaDeDestacados(destacados) {
		return destacados.add(self.listaDeOrganizadores(), self.listaDeCapitanes())
	}

	method destacadoEstrella(destacados, unSocio, unClub) {
		return self.listaDeDestacados(destacados).filter({ socio => socio.esEstrella() })
	}

}

